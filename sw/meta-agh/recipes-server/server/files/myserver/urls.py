from django.urls import path
from . import views

urlpatterns = [
    path('', views.home, name='home'),
    path('start_dsp_tester', views.start_dsp_tester, name='start_dsp_tester'),
    path('upload_data', views.upload_data, name='upload_data'),
    path('led_toggle', views.led_toggle, name='led_toggle'),
    path('svg/<path:filename>/', views.get_svg, name='get_svg'),
    path('start_dsp_controller', views.start_dsp_controller, name='start_dsp_controller'),
    path('load_input_signal', views.load_input_signal, name='load_input_signal'),
    path('get_fir_coefficients', views.get_fir_coefficients, name='get_fir_coefficients'),
    path('get_input_files', views.get_input_files, name='get_input_Files'),
    path('copy_signal', views.copy_signal, name='copy_signal'),
]
