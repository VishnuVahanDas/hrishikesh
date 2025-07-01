from django.contrib import admin
from .models import AppUsageLog

@admin.register(AppUsageLog)
class AppUsageLogAdmin(admin.ModelAdmin):
    list_display = ['timestamp', 'top_app']
    ordering = ['-timestamp']
