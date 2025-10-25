@echo on

REM 简单的Maven安装脚本
REM 创建临时工作目录
mkdir maven_install 2>nul
cd maven_install

echo 1. 正在下载Maven 3.8.8...
powershell -Command "Invoke-WebRequest -Uri 'https://archive.apache.org/dist/maven/maven-3/3.8.8/binaries/apache-maven-3.8.8-bin.zip' -OutFile 'maven.zip' -UseBasicParsing"

REM 检查下载是否成功
if exist maven.zip (
    echo 2. Maven下载成功！正在解压...
    powershell -Command "Expand-Archive -Path 'maven.zip' -DestinationPath '.' -Force"
    
    if exist apache-maven-3.8.8 (
        echo 3. 解压成功！正在安装到E盘...
        mkdir E:\apache-maven-3.8.8 2>nul
        xcopy apache-maven-3.8.8 E:\apache-maven-3.8.8 /E /I /H /Y
        
        echo 4. Maven安装完成！创建本地仓库...
        mkdir E:\maven-repo 2>nul
        
        echo 5. Maven安装信息：
        echo ===================================
        echo 安装路径：E:\apache-maven-3.8.8
        echo 本地仓库：E:\maven-repo
        echo ===================================
        echo.
        echo 请手动配置以下环境变量：
        echo 1. 新建系统变量 MAVEN_HOME = E:\apache-maven-3.8.8
        echo 2. 编辑系统变量 Path，添加 %%MAVEN_HOME%%\bin
        echo 3. 完成后打开新命令提示符，输入 mvn -v 验证安装
    ) else (
        echo 错误：解压失败！
    )
) else (
    echo 错误：下载失败！请检查网络连接。
)

REM 清理临时文件
cd ..
rd /s /q maven_install 2>nul

echo 安装脚本执行完成！
pause