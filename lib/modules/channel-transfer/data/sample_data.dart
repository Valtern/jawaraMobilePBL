import '../models/channel_transfer.dart';

class ChannelTransferSamples {
  ChannelTransferSamples._();

  static final List<ChannelTransfer> channelList = [
    const ChannelTransfer(
      name: 'Rekening BRI RW 05',
      type: 'Bank Transfer',
      accountName: 'A/N RW 05 Kelurahan Sukamaju',
      thumbnailUrl: 'https://logo.clearbit.com/bri.co.id',
    ),
    const ChannelTransfer(
      name: 'QRIS Jawara Pintar',
      type: 'QRIS',
      accountName: 'A/N Jawara Pintar',
      thumbnailUrl:
          'https://storage.googleapis.com/finantier-public/qris-logo.png',
    ),
    const ChannelTransfer(
      name: 'OVO RW 05',
      type: 'E-Wallet',
      accountName: 'A/N RW 05 Kelurahan Sukamaju',
      thumbnailUrl: 'https://logo.clearbit.com/ovo.id',
    ),
  ];
}
