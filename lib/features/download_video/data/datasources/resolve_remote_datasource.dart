import '../../../../core/constants/api_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/dio_client.dart';
import '../models/resolved_video_model.dart';

abstract class ResolveRemoteDataSource {
  Future<ResolvedVideoModel> resolve(String url);
}

class ResolveRemoteDataSourceImpl implements ResolveRemoteDataSource {
  final DioClient _client;
  ResolveRemoteDataSourceImpl(this._client);

  @override
  Future<ResolvedVideoModel> resolve(String url) async {
    final response = await _client.postJson<Map<String, dynamic>>(
      ApiConstants.resolveEndpoint,
      {'url': url},
    );
    final data = response.data;
    if (data == null || data['success'] != true) {
      throw ServerException('Malformed response from resolver.');
    }
    return ResolvedVideoModel.fromJson(data);
  }
}
