var express = require('express');
var app = express();
var http = require('http');
var server = http.createServer(app);
var socketio = require('socket.io');
var io = socketio.listen(server);
var compress = require('compression');
var bodyParser = require('body-parser')


var clients = {};


io.on('connection', function(socket){
  console.log('a user connected ' + socket.id);
  clients[socket.id] = socket;
  socket.on('disconnect', function(){
    console.log('user disconnected ' + socket.id);
    if(!clients.hasOwnProperty(socket.id)){
      console.log('cannot delete socket');
      return;
    }
    delete clients[socket.id];
  });
});

app.use(bodyParser.json());       // to support JSON-encoded bodies
app.use(bodyParser.urlencoded({     // to support URL-encoded bodies
  extended: true
}));

app.post('/password', function(req, res){
  console.log('got password post');
  if(!req.body){
    console.log('no body');
    res.send('bad');
    return;
  }
  if(!req.body.browserid){
    console.log('no browserid');
    res.send('bad');
    return;
  }
  if(!req.body.apppublickey){
    console.log('no apppublickey');
    res.send('bad');
    return;
  }
  if(!req.body.nonce){
    console.log('no nonce');
    res.send('bad');
    return;
  }
  if(!req.body.ciphertext){
    console.log('no ciphertext');
    res.send('bad');
    return;
  }
  if(!req.body.version){
    console.log('no version');
    res.send('bad');
    return;
  }
  if(!clients.hasOwnProperty(req.body.browserid)){
    console.log('browser doesn\'t exist');
    res.send('bad');
    return;
  }
  var msg = {'appPublicKey' : req.body.apppublickey,
             'nonce' : req.body.nonce,
             'cipherText' : req.body.ciphertext,
             'version' : 1};
  console.log(msg);
  clients[req.body.browserid].emit('pass server to browser', JSON.stringify(msg));
  
  res.send('ok');
});


app.get('/s/printdebug', function(req, res){
  //console.log('debugging data');
  //for(var i in clients){
  //  console.log('client: ' + i + ' -> ' + clients[i]);
  //}
  res.send('ok');
});

app.post('/s/csp', function(req, res){
  console.log('csp');
  console.log(req.body);
  res.send('ok');
});


app.use(compress());
app.set('etag', 'strong');
app.use(function(req, res, next){
  res.set('Strict-Transport-Security', 'max-age=' + (60*60*24*365*2) + '; includeSubDomains; preload');
  next();
});

app.use(express.static('public'));

app.use(function(req, res, next){
  res.status(404).send('404');
});

server.listen(3000, function () {
  var host = server.address().address;
  var port = server.address().port;
  console.log('Listening at http://%s:%s', host, port);
});
