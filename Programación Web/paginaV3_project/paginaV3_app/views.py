from django.shortcuts import render, redirect
from django.views import View
from django.contrib.auth.models import User
from .models import Producto, Cliente, Carrito
from .forms import RegistroUsuario, LogInUsuario, PerfilUsuario, ContactoForm
from django.contrib import messages
from django.contrib.auth import login, logout, authenticate
from django.contrib.auth.decorators import login_required


def index(request):
    if request.user.is_authenticated:
        items_carrito = Carrito.objects.filter(user=request.user)
        cantidad_items = sum([item.cantidad for item in items_carrito])
        context = {'cantidad_items': cantidad_items}
        return render(request, 'paginaV3_app/index.html', context)
    else:
        return render(request, 'paginaV3_app/index.html')


def categoria(request, val):
    if request.user.is_authenticated:
        items_carrito = Carrito.objects.filter(user=request.user)
        cantidad_items = sum([item.cantidad for item in items_carrito])
        producto = Producto.objects.filter(categoria=val)
        context = {'producto': producto, 'cantidad_items': cantidad_items}
        return render(request, 'paginaV3_app/categoria.html', context)
    else:
        producto = Producto.objects.filter(categoria=val)
        context = {'producto': producto}
        return render(request, 'paginaV3_app/categoria.html', context)


def detalle_producto(request, pk):
    if request.user.is_authenticated:
        items_carrito = Carrito.objects.filter(user=request.user)
        cantidad_items = sum([item.cantidad for item in items_carrito])
        producto = Producto.objects.get(pk=pk)
        context = {'producto': producto, 'cantidad_items': cantidad_items}
        return render(request, 'paginaV3_app/detalle_producto.html', context)
    else:
        producto = Producto.objects.get(pk=pk)
        context = {'producto': producto, }
        return render(request, 'paginaV3_app/detalle_producto.html', context)


def acerca(request):
    if request.user.is_authenticated:
        items_carrito = Carrito.objects.filter(user=request.user)
        cantidad_items = sum([item.cantidad for item in items_carrito])
        context = {'cantidad_items': cantidad_items}
        return render(request, 'paginaV3_app/acerca.html', context)
    else:
        return render(request, 'paginaV3_app/acerca.html')


def contacto(request):
    if request.user.is_authenticated:
        items_carrito = Carrito.objects.filter(user=request.user)
        cantidad_items = sum([item.cantidad for item in items_carrito])
    if request.method == "POST":
        form = ContactoForm(request.POST)
        if form.is_valid():
            form.save()
            form = ContactoForm()
            context = {'form': form, 'cantidad_items': cantidad_items,
                       'mensaje': 'mensaje enviado con exito'}
            return render(request, 'paginaV3_app/contacto.html', context)
    else:
        form = ContactoForm()
    context = {'form': form, }
    return render(request, 'paginaV3_app/contacto.html', context)


def registro(request):
    if request.user.is_authenticated:
        items_carrito = Carrito.objects.filter(user=request.user)
        cantidad_items = sum([item.cantidad for item in items_carrito])
    if request.method == 'POST':
        form = RegistroUsuario(request.POST)
        if form.is_valid():
            form.save()
            new_user = authenticate(
                username=form.cleaned_data['username'],
                password=form.cleaned_data['password1']
            )
            login(request, new_user)
            return redirect('index')
    else:
        form = RegistroUsuario()
    context = {'form': form, }
    return render(request, 'paginaV3_app/registro.html', context)


def log_in(request):
    if request.method == "POST":
        form = LogInUsuario(request, data=request.POST)
        if form.is_valid():
            username = form.cleaned_data.get('username')
            password = form.cleaned_data.get('password')
            user = authenticate(username=username, password=password)
            if user is not None:
                login(request, user)
                return redirect('index')
            else:
                messages.error(request, 'Error')
        else:
            messages.error(request, 'Usuario o contraseña incorrectos')
    form = LogInUsuario()
    context = {'form': form, }
    return render(request, 'paginaV3_app/login.html', context)


def log_out(request):
    logout(request)
    return redirect('index')


def perfil_usuario(request):
    if request.user.is_authenticated:
        items_carrito = Carrito.objects.filter(user=request.user)
        cantidad_items = sum([item.cantidad for item in items_carrito])
    if request.method == "POST":
        form = PerfilUsuario(request.POST)
        if form.is_valid():
            user = request.user
            nombre = form.cleaned_data['nombre']
            direccion = form.cleaned_data['direccion']
            comuna = form.cleaned_data['comuna']
            ciudad = form.cleaned_data['ciudad']
            region = form.cleaned_data['region']
            telefono = form.cleaned_data['telefono']
            zipcode = form.cleaned_data['zipcode']

            obj = Cliente(
                user=user,
                nombre=nombre,
                direccion=direccion,
                comuna=comuna,
                ciudad=ciudad,
                region=region,
                telefono=telefono,
                zipcode=zipcode
            )
            obj.save()
    form = PerfilUsuario()
    context = {'form': form, 'cantidad_items': cantidad_items}
    return render(request, 'paginaV3_app/perfil.html', context)


def direccion(request):
    if request.user.is_authenticated:
        items_carrito = Carrito.objects.filter(user=request.user)
        cantidad_items = sum([item.cantidad for item in items_carrito])
    direc = Cliente.objects.filter(user=request.user)
    context = {'direc': direc, 'cantidad_items': cantidad_items}
    return render(request, 'paginaV3_app/direccion.html', context)


def elimina_dir(request, pk):
    if request.user.is_authenticated:
        items_carrito = Carrito.objects.filter(user=request.user)
        cantidad_items = sum([item.cantidad for item in items_carrito])
    dir = Cliente.objects.get(id=pk)
    dir.delete()
    clientes = Cliente.objects.all()
    form = PerfilUsuario()
    context = {'clientes': clientes, 'form': form,
               'cantidad_items': cantidad_items}
    return render(request, 'paginaV3_app/perfil.html', context)


def actualiza_dir(request, pk):
    if request.user.is_authenticated:
        items_carrito = Carrito.objects.filter(user=request.user)
        cantidad_items = sum([item.cantidad for item in items_carrito])
    cliente = Cliente.objects.get(id=pk)
    if request.method == "POST":
        form = PerfilUsuario(request.POST, instance=cliente)
        if form.is_valid():
            form.save()
            return redirect('direcciones')
    else:
        form = PerfilUsuario(instance=cliente, initial={
            'nombre': cliente.nombre,
            'direccion': cliente.direccion,
            'comuna': cliente.comuna,
            'ciudad': cliente.ciudad,
            'region': cliente.region,
            'telefono': cliente.telefono,
            'zipcode': cliente.zipcode,
        })
    context = {'form': form, 'cantidad_items': cantidad_items}
    return render(request, 'paginaV3_app/actualiza_dir.html', context)


@login_required
def añadir_al_carrito(request, prod_id):
    producto = Producto.objects.get(id=prod_id)
    carrito, created = Carrito.objects.get_or_create(
        user=request.user, producto=producto)
    if not created:
        carrito.cantidad += 1
        carrito.save()
    return redirect('mostrar_carrito')


@login_required
def remover_del_carrito(request, carrito_id):
    carrito = Carrito.objects.get(id=carrito_id)
    carrito.delete()
    return redirect('mostrar_carrito')


@login_required
def aumentar_cantidad(request, carrito_id):
    carrito = Carrito.objects.get(id=carrito_id)
    carrito.cantidad += 1
    carrito.save()
    return redirect('mostrar_carrito')


@login_required
def disminuir_cantidad(request, carrito_id):
    carrito = Carrito.objects.get(id=carrito_id)
    if carrito.cantidad > 1:
        carrito.cantidad -= 1
        carrito.save()
    return redirect('mostrar_carrito')


@login_required
def mostrar_carrito(request):
    items_carrito = Carrito.objects.filter(user=request.user)
    cantidad_items = sum([item.cantidad for item in items_carrito])
    subtotal = sum(item.producto.precio *
                   item.cantidad for item in items_carrito)
    total = subtotal+2800
    context = {'items_carrito': items_carrito,
               'subtotal': subtotal, 'total': total, 'cantidad_items': cantidad_items}
    return render(request, 'paginaV3_app/añadir_al_carrito.html', context)


@login_required
def checkout(request):
    if request.user.is_authenticated:
        item_carrito = Carrito.objects.filter(user=request.user)
        cantidad_item = sum([item.cantidad for item in item_carrito])
    user = request.user
    direccion = Cliente.objects.filter(user=user)
    items_carrito = Carrito.objects.filter(user=user)
    subtotal = sum(item.producto.precio *
                   item.cantidad for item in items_carrito)
    total = subtotal+2800
    context = {'cantidad_items': cantidad_item, 'items_carrito': items_carrito,
               'direccion': direccion, 'subtotal': subtotal, 'total': total, 'user': user}
    return render(request, 'paginaV3_app/checkout.html', context)


@login_required
def borra_carrito(request, user_id):
    user = User.objects.get(id=user_id)
    carrito = Carrito.objects.filter(user=user)
    carrito.delete()
    return render(request, 'paginaV3_app/success.html')
