from django.urls import path
from . import views
from django.contrib.auth import views as auth_view
from .forms import LogInUsuario

urlpatterns = [
    path('', views.index, name='index'),
    path('categoria/<slug:val>', views.categoria, name='categoria'),
    path('detalle_producto/<int:pk>',
         views.detalle_producto, name="detalle_producto"),
    path('acerca/', views.acerca, name='acerca'),
    path('contacto/', views.contacto, name='contacto'),
    path('perfil/', views.perfil_usuario, name='perfil'),
    path('direcciones/', views.direccion, name='direcciones'),
    path('actualiza_dir/<int:pk>', views.actualiza_dir, name='actualiza_dir'),
    path('elimina_dir/<int:pk>', views.elimina_dir, name='elimina_dir'),

    # Carrito
    path('añadir_al_carrito/<int:prod_id>', views.añadir_al_carrito, name='añadir_al_carrito'),
    path('carrito/', views.mostrar_carrito, name='mostrar_carrito'),
    path('remover_del_carrito/<int:carrito_id>',
         views.remover_del_carrito, name='remover_del_carrito'),
    path('aumentar_cantidad/<int:carrito_id>',
         views.aumentar_cantidad, name='aumentar_cantidad'),
    path('disminuir_cantidad/<int:carrito_id>',
         views.disminuir_cantidad, name='disminuir_cantidad'),

    # checkout
    path('checkout/', views.checkout, name='checkout'),
    path('borra_carrito/<int:user_id>',
         views.borra_carrito, name='borra_carrito'),

    ##### Registro y log in de usuario###
    path('registro/', views.registro, name='registro'),
    path('login/', views.log_in, name='login'),
    path('logout/', views.log_out, name='logout')
]
