from django.db import models

class AppUsageLog(models.Model):
    timestamp = models.DateTimeField()
    top_app = models.CharField(max_length=100)
    duration = models.PositiveIntegerField(default=60, help_text="Duration in seconds")

    def __str__(self):
        return f"{self.top_app} at {self.timestamp}"
