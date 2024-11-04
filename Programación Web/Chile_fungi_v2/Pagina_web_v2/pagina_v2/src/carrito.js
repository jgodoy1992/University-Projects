/*Funcion para que el navbar siga al usuario a lo largo de la pagina */
document.addEventListener("DOMContentLoaded", function(){
    window.addEventListener('scroll', function(){
        if(window.scrollY>50){
            document.getElementById('nav-top').classList.add('fixed-top');
            navbar_height=document.querySelector('.navbar').offsetHeight;
            document.body.style.paddingTop=navbar_height+'px';
        }else{
            document.getElementById('nav-top').classList.remove('fixed-top');
            document.body.style.paddingTop=0;
        }
    })
})

function padTo2Digits(num) {
    return num.toString().padStart(2, '0');
  }
  
  function formatDate(date) {
    return [
      padTo2Digits(date.getDate()),
      padTo2Digits(date.getMonth() + 1),
      date.getFullYear(),
    ].join('-');
  }

let label=document.getElementById("label");
let shopping_cart=document.getElementById("shopping-cart");

/* Recupera datos existentes en la memoria local del navegador, pero si no encuentra entonces se le asigna un arreglo vacio*/

let basket=JSON.parse(localStorage.getItem("data")) || [];

/* se utiliza esta funcion para actualizar el icono del carrito en la barra de navegacion */

function calculos(){
    let carrito=document.getElementById("cartAmount")
    carrito.innerHTML=basket.map((x)=>x.item).reduce((x,y)=>x+y,0)
}

calculos();

/* funcion para generar el carrito de compras en la pagina */

function genenrarCarrito(){
    if(basket.length!==0){
        return (shopping_cart.innerHTML=basket.map((x)=>{
            let {id, item}=x
            let search=itemsGourmet.find((y)=>y.id==id)||itemsMagicos.find((y)=>y.id==id)||[];
            return `
            <div class="cart-item">
                <img width="200" src="${search.img}" alt=""></img>
                <div class="detalles">
                    <div class="titulo-precio-x">
                        <h5 class="titulo-precio">
                            <p>${search.nombre}</p>
                            <p class="cart-item-precio">$${search.precio}</p>
                        </h5>
                        <i onclick="quitarItem(${id})" class="bi bi-x-lg"></i>
                    </div>
                    <div class="buttons">
                        <i onclick="disminuir(${id})" class="bi bi-dash-lg"></i>
                        <div id=${id} class="cantidad">
                            ${item}
                        </div>
                        <i onclick="incremento(${id})" class="bi bi-plus-lg"></i>
                    </div>
                    <h4>$${item*search.precio}</h4>
                </div>
            </div>
            `
        }).join(""));
    }else{
        shopping_cart.innerHTML=``
        label.innerHTML=`
        <h2>Carrito Vacío</h2>
        <a href="index.html">
            <button type="btn" class="homeBtn"> Volver a pagina principal</button>
        </a>
        `
    }
}

genenrarCarrito();

function incremento(id){
    let search=basket.find((x)=>x.id===id)
    if(search===undefined){
        basket.push({
            id:id,
            item:1,
        })
    }else{
        search.item+=1;
    } 
    actualizar(id)
    /* funcion para guardar informacion en el almacenamiento del browser de manera local */
    genenrarCarrito();
    localStorage.setItem("data", JSON.stringify(basket)) 
}

function disminuir(id){
    let search=basket.find((x)=>x.id===id)
    if(search===undefined) return
    else if(search.item===0) return
    else{
        search.item-=1;
    } 
    actualizar(id)   
    basket=basket.filter((x)=>x.item!==0)
    genenrarCarrito(); 
    localStorage.setItem("data", JSON.stringify(basket)) 
}

function actualizar(id){
    let search= basket.find((x)=>x.id===id)
    document.getElementById(id).innerHTML=search.item
    calculos()
    totalCompra()
}

/*Funcion para quita items del carrito cada vez que se clickea el icono "X" */

function quitarItem(id){
    basket=basket.filter((y)=>y.id!==id);
    genenrarCarrito();
    totalCompra();
    calculos();
    localStorage.setItem("data", JSON.stringify(basket)) 
}

/* Funcion para el total de la compra */

function totalCompra(){
    if(basket.length!==0){
        let cantidad=basket.map((x)=>{
            let{item, id}=x
            let search=itemsGourmet.find((y)=>y.id==id)||itemsMagicos.find((y)=>y.id==id)||[];
            return item*search.precio
        }).reduce((x,y)=>x+y,0)
        label.innerHTML=`
           <h2>Total Compra: CLP$${cantidad}</h2> 
           <h4>Total en dólares: USD$${Math.round((cantidad/valorDolar)*100)/100}</h4>
           <button class="checkout">Checkout</button>
           <button onclick="vaciarCarrito()" class="vaciar">Vaciar Carrito</button>
        `
    }else return 
}

/*Se realiza la extraccion del valor del dolar al dia de ejecucion. Dentro de la funcion fetch se incluye la funcion total compra pues es la funcion 
que ejecutara los calculos realizados con la data extraida */

let url='https://mindicador.cl/api/dolar/'+formatDate(new Date());

let valorDolar;

fetch(url).then(response=>response.json()).then(data=>{
    valorDolar=data["serie"][0]["valor"];
    totalCompra();
})

function vaciarCarrito(){
    basket=[]
    genenrarCarrito();
    calculos();
    localStorage.setItem("data", JSON.stringify(basket)) 
}

