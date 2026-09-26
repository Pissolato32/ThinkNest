import 'dart:typed_data';

import 'package:share_plus/share_plus.dart';

import '../../domain/export/implementation_pack.dart';

class ShareImplementationPack {
  Future<void> call(ImplementationPack pack) {
    final filename = 'thinknest-${pack.projectId}-v${pack.version}.zip';

    return SharePlus.instance.share(
      ShareParams(
        files: [
          XFile.fromData(
            Uint8List.fromList(pack.zipBytes),
            name: filename,
            mimeType: 'application/zip',
          ),
        ],
        subject: 'ThinkNest Implementation Pack',
        text: 'Implementation Pack ${pack.exportId}',
      ),
    );
  }
}
