import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/database/remote/supabase_service.dart';
import '../../core/errors/failures.dart';
import '../../domain/models/device_model.dart';

abstract class IDeviceRepository {
  Future<(List<DeviceModel>?, Failure?)> getDevices(String childId);
  Future<(DeviceModel?, Failure?)> registerDevice(DeviceModel device);
  Future<(bool, Failure?)> removeDevice(String deviceId);
  Future<(bool, Failure?)> setCurrentDevice(String childId, String deviceId);
}

class DeviceRepositoryImpl implements IDeviceRepository {
  SupabaseClient get _client => SupabaseService.client;

  @override
  Future<(List<DeviceModel>?, Failure?)> getDevices(String childId) async {
    try {
      final result = await _client
          .from('devices')
          .select()
          .eq('child_id', childId)
          .eq('is_active', true)
          .order('last_active_at', ascending: false);
      final devices = (result as List)
          .map((json) => DeviceModel.fromJson(json as Map<String, dynamic>))
          .toList();
      return (devices, null);
    } catch (e) {
      return (null, DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<(DeviceModel?, Failure?)> registerDevice(DeviceModel device) async {
    try {
      // Unset current flag on other devices for this child
      await _client
          .from('devices')
          .update({'is_current': false})
          .eq('child_id', device.childId)
          .eq('is_active', true);

      final response = await _client
          .from('devices')
          .insert(device.copyWith(isCurrent: true).toJson())
          .select()
          .single();
      return (DeviceModel.fromJson(Map<String, dynamic>.from(response)), null);
    } catch (e) {
      return (null, DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<(bool, Failure?)> removeDevice(String deviceId) async {
    try {
      await _client
          .from('devices')
          .update({'is_active': false})
          .eq('id', deviceId);
      return (true, null);
    } catch (e) {
      return (false, DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<(bool, Failure?)> setCurrentDevice(String childId, String deviceId) async {
    try {
      // Unset all current flags for this child
      await _client
          .from('devices')
          .update({'is_current': false})
          .eq('child_id', childId)
          .eq('is_active', true);

      // Set current flag on target device
      await _client
          .from('devices')
          .update({'is_current': true})
          .eq('id', deviceId);

      return (true, null);
    } catch (e) {
      return (false, DatabaseFailure(message: e.toString()));
    }
  }
}
