
PROJECT_NAME=${PWD##*/}

APP_NAME="PBApp"

APP_PATH="$APP_NAME/workspace/Podfile"

NOW_BRANCH=$(git branch)

if [ ! -d "$APP_NAME" ]; then
  git clone git@gitlab.baidao.com:pb/PBApp.git
  cd PBApp
  git checkout dev
  git pull
  cd ..
else
  cd PBApp
  git checkout dev
  git pull
  cd ..
fi

CURRENT_POD_VERSION=$(cat $PROJECT_NAME.podspec | grep 's.version' | grep -o '[0-9]*\.[0-9]*\.[0-9]*')

echo "This current version is $CURRENT_POD_VERSION"

ORIGIN_POD_VALUE=$(cat $APP_PATH | grep $PROJECT_NAME)
NEW_POD_VALUE="    pod '$PROJECT_NAME', '$CURRENT_POD_VERSION'"

echo "ORIGIN_POD_VALUE: $ORIGIN_POD_VALUE"
echo "NEW_POD_VALUE: $NEW_POD_VALUE"

if [[ $ORIGIN_POD_VALUE ]]; then
	echo "s/$ORIGIN_POD_VALUE/$NEW_POD_VALUE/g"

	sed -i "" "s/$ORIGIN_POD_VALUE/$NEW_POD_VALUE/g" $APP_PATH
else
	sed -i "" "/target 'PBApp' do/ a\\
$NEW_POD_VALUE
" $APP_PATH
fi

cat "========================================================="
cat $APP_PATH
cat "========================================================="

cd PBApp/workspace

BRANCH_NAME=CIPodfileUpdpateWith$PROJECT_NAME@$CURRENT_POD_VERSION

git checkout -b $BRANCH_NAME

# pod repo update baidao-ios-ytx-pod-specs

# rm Podfile.lock

# if [[ $(which podh) ]]; then
# 	echo 'podh install'
# 	podh install
# else
# 	echo 'pod install'
# 	pod install
# fi

git config --get user.name 
git config --get user.email
git commit -am "Update podfile by CI: $ORIGIN_POD_VALUE ---> $NEW_POD_VALUE"
git remote -v
git push --set-upstream origin $BRANCH_NAME

cd ..

pwd

ls -l

if [[ -f "merge_request.sh" ]]; then
	echo "Try to Add merge_request with PBApp"
	sh merge_request.sh "CI Update Podfile $PROJECT_NAME@$CURRENT_POD_VERSION" dev
fi

cd ..
