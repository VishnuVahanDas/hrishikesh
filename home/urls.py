from django.urls import path
from . import views

app_name = "home"
urlpatterns = [
    path('dashboard/', views.parent_dashboard, name='parent_dashboard'),
    path('api/track-usage/', views.track_usage),
    path('block-app/', views.block_app, name='block_app'),
    path('set-limit/', views.set_limit, name='set_limit'),
    path('lock-device/', views.lock_device, name='lock_device'),
]
