# Contribute you changes to STEMMUS-SCOPE on CRIB
## Download the source code of STEMMUS-SCOPE model. 
Log in to CRIB, and run this command on terminal to download the source code from GitHub to the current directory on CRIB.
```
git clone git@github.com:EcoExtreML/STEMMUS_SCOPE.git
```
## Configure `git` on your mechine
Configure the user name and email address
```
git config --global user.name "your name"
git config --global user.emial "your email address"
```
## Commit your changes
1. Check status 
Run this command when you want to check the git status, and all modifications that have not yet been recorded by git will be displayed.
```
git status
```
If you are using the latest version of STEMMUS-SCOPE, you should see this message on your terminal.
> On branch main<br>
> Your branch is up to data with 'origin/main'


2. Create a new branch<br>
Create your working branch. Here we create a new branch called "kosugi"

```
git checkout -b kosugi
```
Run `git status` to see the current status. Here you should be on the 'kosugi' branch.

3. Edit your source code.
4. Run `git status` to check the changes. The changed files will be listed on the terminal.
5. To record your changes, run  `git add <filename>`. For example: if you modified 'STEMMUS_SCOPE.m' file, run
```
git add STEMMUS_SCOPE.m
```

6. Add a comment about your changes, for example:
```
git commit -m "Add kosugi options into STEMMUS-SCOPE"
```
7. Repeat 3-6 to recode all your changes.
8. Uploading your changes to GitHub repository<br>
Use `-u` to set the remote upstream when creating a new branch.
```
git push -u origin kosugi
git push
```



