from django.db import models
from django.contrib.auth.models import User


class Producto(models.Model):
    CATEGORIAS = (
        ('HG', 'Hongos Gourmet'),
        ('EM', 'Esporas Psilocybes'),
    )
    titulo = models.CharField(max_length=100)
    precio = models.IntegerField()
    descripcion = models.TextField()
    categoria = models.CharField(choices=CATEGORIAS, max_length=2)
    prod_imagen = models.ImageField(upload_to='producto')

    def __str__(self):
        return self.titulo


class Cliente(models.Model):
    id = models.AutoField(primary_key=True)
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    nombre = models.CharField(max_length=200)
    direccion = models.CharField(max_length=200)
    comuna = models.CharField(max_length=50)
    ciudad = models.CharField(max_length=50)
    region = models.CharField(max_length=50)
    telefono = models.IntegerField()
    zipcode = models.IntegerField()

    def __str__(self):
        return self.nombre


class Carrito(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    producto = models.ForeignKey(Producto, on_delete=models.CASCADE)
    cantidad = models.PositiveIntegerField(default=1)

    @property
    def costo_total(self):
        return self.cantidad*self.producto.precio


class Contacto(models.Model):
    nombre = models.CharField(max_length=50)
    email = models.EmailField()
    mensaje = models.TextField()

    def __str__(self):
        return self.nombre
