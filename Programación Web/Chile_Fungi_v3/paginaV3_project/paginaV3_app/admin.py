from django.contrib import admin
from .models import Producto, Cliente, Carrito, Contacto


@admin.register(Producto)
class ModelProductoAdmin(admin.ModelAdmin):
    list_display = ['id', 'titulo', 'precio',
                    'descripcion', 'categoria', 'precio', 'prod_imagen']


@admin.register(Cliente)
class ModelClienteAdmin(admin.ModelAdmin):
    list_display = ['id', 'user', 'nombre',
                    'direccion', 'comuna', 'ciudad', 'region', 'telefono', 'zipcode']


@admin.register(Carrito)
class ModelCarritoAdmin(admin.ModelAdmin):
    list_display = ['id', 'user', 'producto', 'cantidad']


@admin.register(Contacto)
class ModelContactoAdmin(admin.ModelAdmin):
    list_display = ['id', 'nombre', 'email', 'mensaje']
