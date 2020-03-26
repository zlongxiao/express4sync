#express4sync

###环境准备
centos 7

###部署
1. 获取deploy.sh
wget https://github.com/zlongxiao/express4sync/blob/master/deploy.sh

2. 添加可执行权限 
chmod 777 deploy.sh

3. 执行
./deploy.sh
(请根据提示输入相应的指令)

4. 以上执行完成后，可以在本机或局域网访问，如
http://192.168.0.113:8384/

5. 打开网址后，做如下处理
    1. [设置用户名，密码及删除默认文件夹](http://pmr.forke.cn:16666/api/alien/download/97e74dd8-f1f2-4f3a-5c14-3063161c840a/s1.png)



2. npm install  //安装node运行环境

3. gulp build   //前端编译

4. 启动两个配置(已forever为例)
    eg: forever start app-service.js
        forever start logger-service.js