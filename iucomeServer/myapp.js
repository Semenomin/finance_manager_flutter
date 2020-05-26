const express = require('express');
const app = express();
var pgp = require("pg-promise")();
var conf = require("./db_config.json");

const connectionConf = {
  host: conf.host,
  port: conf.port,
  database: conf.database,
  user: conf.user,
  password: conf.password
}

var db = pgp(connectionConf);

app.get('/debts',function(req,res){
  db.result('select * from get_debt_by_id($1)',[req.query.user_id]).then((data)=>{
    res.send(data);
  })
})

app.get('/debts/add',function(req,res){
  let dbString = `select add_debt(${req.query.user_id},${req.query.cash},${req.query.person},${req.query.is_income})`;
  db.result(dbString);
  res.send('ok');
})

app.get('/debts/close',function(req,res){
  let dbString = `update debts set close=true where user_id=${req.query.user_id} and person=${req.query.person}`
  db.result(dbString);
  res.send('ok');
})

app.get('/debts/open',function(req,res){
  let dbString = `update debts set close=false where user_id=${req.query.user_id} and person=${req.query.person}`
  db.result(dbString);
  res.send('ok');
})

//Create user
app.post('/users/create', function(req,res){
  db.result("Select create_user($1,$2)",[req.query.login,req.query.pass]).then((data)=>{
    if(data.rows[0].create_user != null) res.send(data.rows[0].create_user);
    else res.send('none');
  });
})

//auth
app.post('/users/auth', function(req,res){
  db.result("Select check_password_by_login($1,$2)",[req.query.login,req.query.pass]).then((data)=>{
    console.log("Auth",req.query.login,req.query.pass);
    if(data.rows[0].check_password_by_login != null)
    res.send(`${data.rows[0].check_password_by_login}`);
    else res.send('none');
  });
})

//add expense
app.post('/db/createEx',(req,res)=>{
  db.result('select add_expense($1,$2,$3,$4,$5);',[req.query.name,req.query.cash,req.query.category,req.query.user,req.query.wallet]).then((data)=>{
    res.send(data);
  });
})

//add income
app.post('/db/createInc',(req,res)=>{
  db.result('select add_income($1,$2,$3,$4);',[req.query.name,req.query.cash,req.query.category,req.query.user]).then((data)=>{
    res.send(data);
  });
})

app.get('/db/expenses',(req,res)=>{
  db.result('select * from get_expenses_by_id($1,$2)',[req.query.user_id,req.query.date]).then((data)=>{
    res.send(data);
  })
})

app.get('/db/incomes',(req,res)=>{
  db.result('select * from get_incomes_by_id($1,$2)',[req.query.user_id,req.query.date]).then((data)=>{
    res.send(data);
  })
})

app.get('/',(req,res)=>{
  res.send("ok");
})

app.listen(3002, function () {
  console.log('Example app listening on port 3002!');
});