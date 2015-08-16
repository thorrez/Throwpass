numPasswords = 0;
qrcode = null;
precomputed = null;
keyPair = null;
passwordVisible = false;

function getOrdinal(n) {
  var s=["th","st","nd","rd"];
  var v=n%100;
  return n+(s[(v-20)%10]||s[v]||s[0]);
}

function ui8a2hex(ua){
  var h = '';
  for (var i = 0; i < ua.length; i++){
    h += (Math.floor(ua[i]/16)).toString(16) + (ua[i] % 16).toString(16);
  }
  return h;
}

function hex2ui8a(h){
  var ui8a = new Uint8Array(Math.floor((h.length + 1)/2));
  for (var i = 0; i < ui8a.length; i++){
    ui8a[i] = parseInt(h.substr(i*2, 2), 16);
  }
  return ui8a;
}

function doWork(){
  var socket = io();
  var stat = document.getElementById('status');
  var pwBox = document.getElementById('password');
  var toggleButton = document.getElementById('togglebutton');
  var infoDiv = document.getElementById('info');

  socket.on('connect', function () {
    if(qrcode){
      qrcode.clear();
    }else{
      qrcode = new QRCode("qrcode");
    }
    var qrcodeVal = {
      'v': 1,
      'pbk' : btoa(String.fromCharCode.apply(null, keypair.publicKey)),
      'id' : socket.io.engine.id
    }
    qrcode.makeCode(JSON.stringify(qrcodeVal));
    stat.textContent = 'Scan QR Code with app';
    document.getElementById('id').textContent = 'ID: ' + qrcodeVal.id;
    document.getElementById('pbk').textContent = 'Public key: ' + qrcodeVal.pbk;
    infoDiv.style.display= 'block';
    document.getElementById('id').style.visibility = 'visible';
    document.getElementById('pbk').style.visibility = 'visible';
    infoDiv.style.visibility= 'visible';
    infoDiv.style.visibility= 'visible';
  });

  socket.on('pass server to browser', function(msg){
    var msg = JSON.parse(msg);
    console.log('appPublicKey: ' + msg.appPublicKey);
    console.log('nonce: ' + msg.nonce);
    console.log('version: ' + msg.version);
    console.log('cipherText: ' + msg.cipherText);
    if(!precomputed){
      var appPublicKey = hex2ui8a(msg.appPublicKey);
      precomputed = nacl.box.before(appPublicKey, keypair.secretKey);
    }
    var nonce =  hex2ui8a(msg.nonce);
    var cipherText = hex2ui8a(msg.cipherText);
    var password = nacl.box.open.after(cipherText, nonce, precomputed);
    pwBox.value = nacl.util.encodeUTF8(password);

    ++numPasswords;
    var newStatus;
    if(numPasswords > 1){
      newStatus = getOrdinal(numPasswords) + ' password received. Control-c to copy it.'
    }
    else{
      newStatus = 'Password received. Control-c to copy it.';
    }
    stat.textContent = newStatus;
    
    infoDiv.style.display = 'none';
    document.getElementById('selectbutton').style.display = 'block';
    toggleButton.style.display = 'block';
    hidePassword();
  });
  
  selectPassword = function(){
    pwBox.focus();
    pwBox.select();
  }
  
  togglePassword = function(){
    if(passwordVisible){
      hidePassword();
    }else{
      pwBox.style.fontSize = '10px';
      pwBox.style.color = 'black';
      pwBox.style.width = 'auto';
      pwBox.style.height = 'auto';
      pwBox.style.border = 'initial';
      pwBox.style.borderStyle = 'initial';
      toggleButton.textContent = 'Hide password';
      passwordVisible = true;
    }
  }

  hidePassword = function(){
    toggleButton.textContent = 'Display password';
    pwBox.style.fontSize = '1px';
    pwBox.style.color = 'white';
    pwBox.style.width = '1px';
    pwBox.style.height = '1px';
    pwBox.style.border = '0px none white';
    passwordVisible = false;
    selectPassword();
  }

  document.getElementById('selectbutton')
          .addEventListener('click', selectPassword);
  document.getElementById('togglebutton')
          .addEventListener('click', togglePassword);

  keypair = nacl.box.keyPair();
  stat.textContent = 'Getting ID from server';
}

document.addEventListener('DOMContentLoaded', doWork);
