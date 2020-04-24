# Sentry-Docker


## 安装Docker
```
$ curl -fsSL https://get.docker.com/ | sh
$ yum install docker-compose
$ systemctl restart docker
$ systemctl enable docker

```

## 自动安装


```
$ sh install.sh
```


## 手动Sentry

1. Pull

```
$ git clone https://github.com/bluehole333/docker_sentry.git
```

2. 生成SecretKey, 复制到.env中
```
$ cd docker_sentry
$ docker-compose run --rm web config generate-secret-key

# https://hub.docker.com/_/postgres
# 如果碰到运行错误ERROR: Volume sentry-data declared as external, but could not be found. Please create the volume manually using `docker volume create --name=sentry-data` and try again
$ docker volume create --name=sentry-data
$ docker volume create --name=sentry-postgres
```

3. 创建数据库和超级管理员
```
$ docker-compose run --rm web upgrade
```

4. 启动服务
```
$ docker-comose up -d
```

5. Run

```
http://localhost:9000 
```

