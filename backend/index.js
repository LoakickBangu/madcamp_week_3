const Koa = require("koa")
const Router = require("koa-router")
const consola = require("consola")
const koaBody = require("koa-body")
const mongoose = require("mongoose")
const Schema = mongoose.Schema
const { jwtMiddleware } = require("lib/token")

consola.wrapConsole()

//서버 생성
const app = new Koa()
const port = 3005

//소켓서버
const http = require('http')
const createSocketServer = require("socket/index")
const server = http.createServer(app.callback())

//시작 함수
const start = async () => {
  //DB 연결
  await mongoose.connect("mongodb://localhost:27017/kaimarket", {
    useNewUrlParser: true
  })
  const db = require("lib/db")
  app.use((ctx, next) => {
    ctx.db = db
    return next()
  })

  //바디 파서
  app.use(koaBody())

  //JWT 인증
  app.use(jwtMiddleware)  

  //라우터 연결
  const router = new Router()
  const api = require("./api")
  router.use("/api", api.routes())
  app.use(router.routes()).use(router.allowedMethods())

  server.listen(port)
  createSocketServer(server)

  console.ready({
    message: `서버 오픈 :) ${port} >_ <`,
    badge: true
  })
}

start()