#echo "# Burp" >> README.md
git init
#git add README.md
update_desc=$1
git add *
git commit -m "$1"
git remote add origin git@github.com:Supertao/codeql.git
git push -u origin master -f
