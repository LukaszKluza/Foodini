import 'package:frontend/services/user_provider.dart';
import 'package:mockito/annotations.dart';
import 'package:http/http.dart' as http;

@GenerateMocks([http.Client, UserProvider])
void main() {}
