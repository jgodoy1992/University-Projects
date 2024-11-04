
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

/* construccion de elementos del div shop gourmet y psilocybes */

let shop_gourmet=document.getElementById("shop-gourmet");
let shop_magicos=document.getElementById("shop-magicos");

/* Recupera datos existentes en la memoria local del navegador, pero si no encuentra entonces se le asigna un arreglo vacio*/

let basket=JSON.parse(localStorage.getItem("data")) || [];

function generarShopGourmet(){
    return (shop_gourmet.innerHTML= itemsGourmet.map(function(x){
        let {collapsing,id,img,nombre,desc,precio}=x;
        /* si buscan valores almacenados en la memoria del navegador, que los muestre por el div de cantidad, en caso contrario que sea un arreglo vacio*/
        let search=basket.find((y)=>y.id==id)||[];
        return `
        <div id=producto-id-${id} class="item">
            <img width="206" src=${img} alt="">
            <div class="detalles">
                <h3>${nombre}</h3>
                <div class="descripcion">
                    <button type="button" class="btn btn-light" data-bs-toggle="modal" data-bs-target="#modalDesc-${collapsing}">
                        Descripcion
                    </button>
                </div>
                
                <div class="precio-cantidad">
                    <h4>$${precio}</h4>
                    <div class="buttons">
                        <i onclick="disminuir(${id})" class="bi bi-dash-lg"></i>
                        <div id=${id} class="cantidad">${search.item===undefined? 0: search.item}</div>
                        <i onclick="incremento(${id})" class="bi bi-plus-lg"></i>
                    </div>
                </div>
            </div>
        </div>
        
        <div class="modal fade" id="modalDesc-${collapsing}" data-bs-backdrop="static" data-bs-keyboard="false" tabindex="-1" aria-labelledby="modalDesc-${collapsing}" aria-hidden="true">
            <div class="modal-dialog">
                <div class="modal-content">
                    <div class="modal-header">
                        <h1 class="modal-title fs-5" id="staticBackdropLabel">${nombre}</h1>
                        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                    </div>
                    <div class="modal-body">
                        ${desc}
                    </div>
                </div>
            </div>
        </div>
        `
    }).join(""))
}

generarShopGourmet();

function generarShopMagicos(){
    return (shop_magicos.innerHTML= itemsMagicos.map(function(x){
        let {collapsing,id,img,nombre,desc,precio}=x;
        /* si buscan valores almacenados en la memoria del navegador, que los muestre por el div de cantidad, en caso contrario que sea un arreglo vacio*/
        let search=basket.find((y)=>y.id==id)||[];
        return `
        <div id=producto-id-${id} class="item">
            <img width="206" src=${img} alt="">
            <div class="detalles">
                <h3>${nombre}</h3>
                <div class="descripcion">
                    <button type="button" class="btn btn-light" data-bs-toggle="modal" data-bs-target="#modalDesc-${collapsing}">
                        Descripcion
                    </button>
                </div>
                
                <div class="precio-cantidad">
                    <h4>$${precio}</h4>
                    <div class="buttons">
                        <i onclick="disminuir(${id})" class="bi bi-dash-lg"></i>
                        <div id=${id} class="cantidad">${search.item===undefined? 0: search.item}</div>
                        <i onclick="incremento(${id})" class="bi bi-plus-lg"></i>
                    </div>
                </div>
            </div>
        </div>
        
        <div class="modal fade" id="modalDesc-${collapsing}" data-bs-backdrop="static" data-bs-keyboard="false" tabindex="-1" aria-labelledby="modalDesc-${collapsing}" aria-hidden="true">
            <div class="modal-dialog">
                <div class="modal-content">
                    <div class="modal-header">
                        <h1 class="modal-title fs-5" id="staticBackdropLabel">${nombre}</h1>
                        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                    </div>
                    <div class="modal-body">
                        ${desc}
                    </div>
                </div>
            </div>
        </div>
        `
    }).join(""))
}

generarShopMagicos();

/* Creacion de funciones para incrementar, disminuir, actualizar cantidades de producto y calcular el total de producto agregado al carrito*/

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
    localStorage.setItem("data", JSON.stringify(basket)) 
}

function actualizar(id){
    let search= basket.find((x)=>x.id===id)
    document.getElementById(id).innerHTML=search.item
    calculos()
}

function calculos(){
    let carrito=document.getElementById("cartAmount")
    carrito.innerHTML=basket.map((x)=>x.item).reduce((x,y)=>x+y,0)
}

calculos();