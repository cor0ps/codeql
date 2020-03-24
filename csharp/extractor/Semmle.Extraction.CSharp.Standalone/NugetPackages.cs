﻿using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO;
using System.Linq;
using System.Security.Cryptography;
using System.Text;

namespace Semmle.BuildAnalyser
{
    /// <summary>
    /// Manage the downloading of NuGet packages.
    /// Locates packages in a source tree and downloads all of the
    /// referenced assemblies to a temp folder.
    /// </summary>
    class NugetPackages
    {
        /// <summary>
        /// Create the package manager for a specified source tree.
        /// </summary>
        /// <param name="sourceDir">The source directory.</param>
        public NugetPackages(string sourceDir)
        {
            SourceDirectory = sourceDir;
            PackageDirectory = computeTempDirectory(sourceDir);

            // Expect nuget.exe to be in a `nuget` directory under the directory containing this exe.
            var currentAssembly = System.Reflection.Assembly.GetExecutingAssembly().Location;
            nugetExe = Path.Combine(Path.GetDirectoryName(currentAssembly), "nuget", "nuget.exe");

            if (!File.Exists(nugetExe))
                throw new FileNotFoundException(string.Format("NuGet could not be found at {0}", nugetExe));
        }

        /// <summary>
        /// Locate all NuGet packages but don't download them yet.
        /// </summary>
        public void FindPackages()
        {
            packages = new DirectoryInfo(SourceDirectory).
                EnumerateFiles("packages.config", SearchOption.AllDirectories).
                ToArray();
        }

        // List of package files to download.
        FileInfo[] packages;

        /// <summary>
        /// The list of package files.
        /// </summary>
        public IEnumerable<FileInfo> PackageFiles => packages;

        // Whether to delete the packages directory prior to each run.
        // Makes each build more reproducible.
        const bool cleanupPackages = true;

        public void Cleanup(IProgressMonitor pm)
        {
            var packagesDirectory = new DirectoryInfo(PackageDirectory);

            if (packagesDirectory.Exists)
            {
                try
                {
                    packagesDirectory.Delete(true);
                }
                catch (System.IO.IOException ex)
                {
                    pm.Warning(string.Format("Couldn't delete package directory - it's probably held open by something else: {0}", ex.Message));
                }
            }
        }

        /// <summary>
        /// Download the packages to the temp folder.
        /// </summary>
        /// <param name="pm">The progress monitor used for reporting errors etc.</param>
        public void InstallPackages(IProgressMonitor pm)
        {
            if (cleanupPackages)
            {
                Cleanup(pm);
            }

            var packagesDirectory = new DirectoryInfo(PackageDirectory);

            if (!Directory.Exists(PackageDirectory))
            {
                packagesDirectory.Create();
            }

            foreach (var package in packages)
            {
                RestoreNugetPackage(package.FullName, pm);
            }
        }

        /// <summary>
        /// The source directory used.
        /// </summary>
        public string SourceDirectory
        {
            get;
            private set;
        }

        /// <summary>
        /// The computed packages directory.
        /// This will be in the Temp location
        /// so as to not trample the source tree.
        /// </summary>
        public string PackageDirectory
        {
            get;
            private set;
        }

        readonly SHA1CryptoServiceProvider sha1 = new SHA1CryptoServiceProvider();

        /// <summary>
        /// Computes a unique temp directory for the packages associated
        /// with this source tree. Use a SHA1 of the directory name.
        /// </summary>
        /// <param name="srcDir"></param>
        /// <returns>The full path of the temp directory.</returns>
        string computeTempDirectory(string srcDir)
        {
            var bytes = Encoding.Unicode.GetBytes(srcDir);

            var sha = sha1.ComputeHash(bytes);
            var sb = new StringBuilder();
            foreach (var b in sha.Take(8))
                sb.AppendFormat("{0:x2}", b);

            return Path.Combine(Path.GetTempPath(), "Semmle", "packages", sb.ToString());
        }

        /// <summary>
        /// Restore all files in a specified package.
        /// </summary>
        /// <param name="package">The package file.</param>
        /// <param name="pm">Where to log progress/errors.</param>
        void RestoreNugetPackage(string package, IProgressMonitor pm)
        {
            pm.NugetInstall(package);

            /* Use nuget.exe to install a package.
             * Note that there is a clutch of NuGet assemblies which could be used to
             * invoke this directly, which would arguably be nicer. However they are
             * really unwieldy and this solution works for now.
             */

            string exe, args;
            if (Util.Win32.IsWindows())
            {
                exe = nugetExe;
                args = string.Format("install -OutputDirectory {0} {1}", PackageDirectory, package);
            }
            else
            {
                exe = "mono";
                args = string.Format("{0} install -OutputDirectory {1} {2}", nugetExe, PackageDirectory, package);
            }

            var pi = new ProcessStartInfo(exe, args)
            {
                RedirectStandardOutput = true,
                RedirectStandardError = true,
                UseShellExecute = false
            };

            try
            {
                using (var p = Process.Start(pi))
                {
                    string output = p.StandardOutput.ReadToEnd();
                    string error = p.StandardError.ReadToEnd();

                    p.WaitForExit();
                    if (p.ExitCode != 0)
                    {
                        pm.FailedNugetCommand(pi.FileName, pi.Arguments, output + error);
                    }
                }
            }
            catch (Exception ex)
                when (ex is System.ComponentModel.Win32Exception || ex is FileNotFoundException)
            {
                pm.FailedNugetCommand(pi.FileName, pi.Arguments, ex.Message);
            }
        }

        readonly string nugetExe;
    }
}
