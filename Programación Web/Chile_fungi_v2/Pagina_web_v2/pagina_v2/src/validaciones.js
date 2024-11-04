document.addEventListener('DOMContentLoaded', function() {
    let form_cont = document.querySelector('#formulario-contacto');
    let email_contacto = document.querySelector('#mail');
    let tel_contacto = document.querySelector('#telefono');
    let error_contacto = document.querySelector('#error-contacto');
    
    let form_reg = document.querySelector('#formulario-registro');
    let email_reg = document.querySelector('#email-registro');
    let pass1_reg = document.querySelector('#password');
    let pass2_reg = document.querySelector('#confirm-password');
    let zip = document.querySelector('#zip');
    let error_reg = document.querySelector('#error-registro');
  
    let rxMail = /^[a-zA-Z]+[a-zA-Z0-9_.]+@[a-zA-Z.]+\.[a-zA-Z]+$/;
    let rxTel = /^([0-9]+){8}$/;
    let rxClave = /^([a-zA-Z0-9_.!#$%&'*+]+){8,}$/;
    let rxZip = /^([0-9]+){7}/;
    
    form_cont.addEventListener('submit', function(ev) {
      ev.preventDefault();
      let mensajeError = [];
  
      if (!email_contacto.value.match(rxMail)) {
        mensajeError.push('Email inválido');
      }
  
      if (!tel_contacto.value.match(rxTel)) {
        mensajeError.push('Nº de telefono inválido');
      }
  
      if (mensajeError.length === 0) {
        ev.target.submit();
        alert('Mensaje enviado con exito!');
        console.log('submitted');
      } else {
        error_contacto.innerHTML = mensajeError.join(', ');
      }
    });
  
    form_reg.addEventListener('submit', function(ev) {
      ev.preventDefault();
      let mensajeError = [];
  
      if (!email_reg.value.match(rxMail)) {
        mensajeError.push('Email inválido');
      }
  
      if (!pass1_reg.value.match(rxClave)) {
        mensajeError.push('La clave de debe tener 8 caracteres, almenos una letra mayuscula, una letra minuscula, un numero y un simbolo');
      }
  
      if (!(pass1_reg.value === pass2_reg.value)) {
        mensajeError.push('claves deben coinsidir');
      }
  
      if(!zip.value.match(rxZip)){
        mensajeError.push('ZIP inválido');
      }
  
      if (mensajeError.length === 0) {
        ev.target.submit();
        alert('Registro exitoso!');
        console.log('submitted');
      } else {
        error_reg.innerHTML = mensajeError.join('<br>');
      }
    });
  });

