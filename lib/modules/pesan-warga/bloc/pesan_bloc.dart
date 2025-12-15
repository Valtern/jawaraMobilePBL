import 'dart:async';
import 'package:jawarapbl/modules/pesan-warga/models/pesan_model.dart';
import 'package:jawarapbl/services/pesan_service.dart';

class PesanBloc {
  final PesanService _service = PesanService();

  final _pesanController = StreamController<List<Pesan>>.broadcast();
  
  Stream<List<Pesan>> get pesanStream => _pesanController.stream;

  final _eventController = StreamController<void>();
  Sink<void> get eventSink => _eventController.sink;

  PesanBloc() {
    _eventController.stream.listen((_) {
      _loadPesan();
    });
  }

  void _loadPesan() async {
    try {
      final pesanList = await _service.getInbox();
      _pesanController.sink.add(pesanList); 
    } catch (e) {
      _pesanController.sink.addError(e);
    }
  }

  void dispose() {
    _pesanController.close();
    _eventController.close();
  }
}