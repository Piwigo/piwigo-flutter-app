class StatusModel {
  String username;
  String status;
  String? theme;
  String language;
  String pwgToken;
  String charset;
  String? currentDatetime;
  String version;
  List<String> availableSizes;
  String? uploadFileTypes;
  int? uploadFormChunkSize;

  StatusModel.fromJson(Map<String, dynamic> json)
      : username = json['username'] ?? 'guest',
        status = json['status'] ?? 'guest',
        theme = json['theme'],
        language = json['language'] ?? 'en_US',
        pwgToken = json['pwg_token'] ?? '',
        charset = json['charset'] ?? 'utf-8',
        currentDatetime = json['current_datetime'],
        version = json['version'],
        availableSizes = json['available_sizes'].cast<String>(),
        uploadFileTypes = json['upload_file_types'],
        uploadFormChunkSize = json['upload_form_chunk_size'];
}
