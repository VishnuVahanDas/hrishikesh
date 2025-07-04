# Generated by Django 5.2.3 on 2025-07-01 18:16

from django.db import migrations, models


class Migration(migrations.Migration):

    initial = True

    dependencies = [
    ]

    operations = [
        migrations.CreateModel(
            name='AppUsageLog',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('timestamp', models.DateTimeField()),
                ('top_app', models.CharField(max_length=100)),
                ('duration', models.PositiveIntegerField(default=60, help_text='Duration in seconds')),
            ],
        ),
    ]
