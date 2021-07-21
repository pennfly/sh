@echo off
@title bat 交互执行git命令
cd C:/Users/Penn/dev/笔记/Study
git add .
git commit -m %date:~0,4%年%date:~5,2%月%date:~8,2%日

pause   