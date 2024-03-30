enum RequestFormatEnum {
  json('json'),
  xml('rest'),
  php('php'),
  xmlRPC('xmlrpc');

  const RequestFormatEnum(this.value);

  final String value;
}
