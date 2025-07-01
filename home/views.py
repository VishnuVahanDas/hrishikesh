from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt, csrf_protect
from django.shortcuts import render, redirect
from django.db.models import Sum
from django.utils.timezone import now, timedelta
import json

from .models import AppUsageLog  # Make sure this model is defined correctly

# Main dashboard view
def parent_dashboard(request):
    device_status = "online"  # You can make this dynamic with ping logic

    # Calculate screen time today
    today = now().date()
    logs_today = AppUsageLog.objects.filter(timestamp__date=today)
    total_seconds = logs_today.aggregate(Sum('duration')).get('duration__sum') or 0
    screen_time = f"{total_seconds // 3600}h {total_seconds % 3600 // 60}m"

    # Most used app today
    top_app_data = logs_today.values('top_app').annotate(total_time=Sum('duration')).order_by('-total_time').first()
    top_app_name = top_app_data['top_app'] if top_app_data else "N/A"

    # Last 24 hours logs
    last_24_hours = now() - timedelta(hours=24)
    recent_logs = AppUsageLog.objects.filter(timestamp__gte=last_24_hours).order_by('-timestamp')

    context = {
        'status': device_status,
        'screen_time': screen_time,
        'top_app': top_app_name,
        'last_updated': "2 mins ago",  # Static for now
        'logs': recent_logs
    }
    return render(request, 'parent_dashboard.html', context)

# Data tracking endpoint (already implemented by you)
@csrf_exempt
def track_usage(request):
    if request.method == 'POST':
        try:
            data = json.loads(request.body)
            timestamp = data.get('timestamp')
            top_app = data.get('top_app')
            duration = data.get('duration') or 60  # Optional: default 1 min if not given

            if not timestamp or not top_app:
                return JsonResponse({'error': 'Missing required fields'}, status=400)

            AppUsageLog.objects.create(
                timestamp=timestamp,
                top_app=top_app,
                duration=duration
            )

            return JsonResponse({'message': 'Usage data recorded successfully'}, status=201)

        except json.JSONDecodeError:
            return JsonResponse({'error': 'Invalid JSON'}, status=400)
        except Exception as e:
            return JsonResponse({'error': str(e)}, status=500)

    return JsonResponse({'error': 'Only POST method is allowed'}, status=405)


# Actions from dashboard (stubs)

@csrf_protect
def block_app(request):
    if request.method == "POST":
        app_package = request.POST.get("package")
        print("Blocked:", app_package)
        return redirect('home:parent_dashboard')

@csrf_protect
def set_limit(request):
    if request.method == "POST":
        limit = request.POST.get("limit")
        print("Limit Set:", limit)
        return redirect('home:parent_dashboard')

@csrf_protect
def lock_device(request):
    if request.method == "POST":
        print("Device lock requested")
        return redirect('home:parent_dashboard')
