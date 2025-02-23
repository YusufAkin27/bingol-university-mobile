import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:social_media/screens/profile_screen.dart';

class PostItem extends StatefulWidget {
  final Map<String, dynamic> post;

  const PostItem({
    Key? key,
    required this.post,
  }) : super(key: key);

  @override
  _PostItemState createState() => _PostItemState();
}

class _PostItemState extends State<PostItem> {
  final _commentController = TextEditingController();
  bool isLiked = false;
  bool isSaved = false;
  bool isRecorded = false;
  List<CommentDTO> comments = [];
  int currentPage = 0;
  bool isLoadingComments = false;
  ScrollController _scrollController = ScrollController();
  int _currentMediaIndex = 0;
  final PageController _mediaController = PageController();

  @override
  void initState() {
    super.initState();
    _checkIfLiked();
    _checkIfRecorded();
    _fetchComments();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _mediaController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      _loadMoreComments();
    }
  }

  Future<void> _checkIfLiked() async {
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('accessToken') ?? '';
    final postId = widget.post['postId'];

    try {
      final response = await http.get(
        Uri.parse('http://localhost:8080/v1/api/likes/post/$postId/check'),
        headers: {
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          isLiked = data;
        });
      }
    } catch (e) {
      print('Beğeni durumu kontrol edilirken hata: $e');
    }
  }

  Future<void> _checkIfRecorded() async {
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('accessToken') ?? '';
    final postId = widget.post['postId'];

    try {
      final response = await http.get(
        Uri.parse('http://localhost:8080/v1/api/post/recorded/$postId/check'),
        headers: {
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          isRecorded = data['data'] ?? false;
        });
      }
    } catch (e) {
      print('Kayıt durumu kontrol edilirken hata: $e');
    }
  }

  Future<void> _fetchComments() async {
    if (isLoadingComments) return;

    setState(() {
      isLoadingComments = true;
    });

    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('accessToken') ?? '';
    final postId = widget.post['postId'];

    try {
      final response = await http.get(
        Uri.parse('http://localhost:8080/v1/api/comments/post/$postId?page=$currentPage&size=10'),
        headers: {
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['data'] is List) {
          final List<CommentDTO> newComments = (data['data'] as List<dynamic>).map((x) {
            return CommentDTO(
              id: x['id']?.toString() ?? '',
              username: x['username'] ?? '',
              profilePhoto: x['profilePhoto'] ?? '',
              content: x['content'] ?? '',
              howManyMinutesAgo: x['howManyMinutesAgo'] ?? '',
            );
          }).toList();

          setState(() {
            if (currentPage == 0) {
              comments = newComments;
            } else {
              comments.addAll(newComments);
            }
          });
        }
      }
    } catch (e) {
      print('Yorumlar yüklenirken hata: $e');
    } finally {
      setState(() {
        isLoadingComments = false;
      });
    }
  }

  Future<void> _loadMoreComments() {
    currentPage++;
    return _fetchComments();
  }

  void _handleDoubleTap() {
    _toggleLike();
  }

  Future<void> _toggleLike() async {
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('accessToken') ?? '';
    final postId = widget.post['postId'];

    try {
      final response = await http.post(
        Uri.parse('http://localhost:8080/v1/api/likes/post/$postId'),
        headers: {
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          isLiked = !isLiked;
          if (isLiked) {
            widget.post['like']++;
          } else {
            widget.post['like']--;
          }
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Bir hata oluştu')),
      );
    }
  }

  Future<void> _toggleSave() async {
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('accessToken') ?? '';
    final postId = widget.post['postId'];

    try {
      if (!isRecorded) {
        final response = await http.post(
          Uri.parse('http://localhost:8080/v1/api/post/record'),
          headers: {
            'Authorization': 'Bearer $accessToken',
          },
          body: {
            'postId': postId,
          },
        );

        if (response.statusCode == 200) {
          setState(() => isRecorded = true);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gönderi kaydedildi')),
          );
        }
      } else {
        final response = await http.delete(
          Uri.parse('http://localhost:8080/v1/api/post/$postId/recorded'),
          headers: {
            'Authorization': 'Bearer $accessToken',
          },
        );

        if (response.statusCode == 200) {
          setState(() => isRecorded = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gönderi kaydedilenlerden kaldırıldı')),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Bir hata oluştu')),
      );
    }
  }

  Future<void> _addComment() async {
    if (_commentController.text.isEmpty) return;

    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('accessToken') ?? '';
    final postId = widget.post['postId'];

    try {
      final response = await http.post(
        Uri.parse('http://localhost:8080/v1/api/comments/post/$postId'),
        headers: {
          'Authorization': 'Bearer $accessToken',
        },
        body: {
          'content': _commentController.text,
        },
      );

      if (response.statusCode == 200) {
        _commentController.clear();
        await _fetchComments();
        setState(() {
          widget.post['comment']++;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Yorum eklenirken bir hata oluştu')),
      );
    }
  }

  Future<void> _deleteComment(String commentId) async {
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('accessToken') ?? '';

    try {
      final response = await http.delete(
        Uri.parse('http://localhost:8080/v1/api/comments/$commentId'),
        headers: {
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        await _fetchComments();
        setState(() {
          widget.post['comment']--;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Yorum silinirken bir hata oluştu')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(8.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      elevation: 5,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProfileScreen(
                      username: widget.post['username'],
                    ),
                  ),
                );
              },
              child: CircleAvatar(
                backgroundImage: NetworkImage(widget.post['profilePhoto']),
              ),
            ),
            title: Text(
              widget.post['username'],
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.post['location'] != null)
                  Text(widget.post['location']),
                _buildPopularityScore(),
              ],
            ),
            trailing: PopupMenuButton(
              itemBuilder: (context) => [
                PopupMenuItem(
                  child: Text('Şikayet Et'),
                  value: 'report',
                ),
                PopupMenuItem(
                  child: Text('Paylaş'),
                  value: 'share',
                ),
              ],
              onSelected: (value) {
                // Menü işlemleri
              },
            ),
          ),
          _buildMediaContent(),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              utf8.decode(widget.post['description'].toString().codeUnits),
              style: TextStyle(fontSize: 14),
            ),
          ),
          if (widget.post['tagAPerson']?.isNotEmpty ?? false)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Wrap(
                spacing: 4,
                children: widget.post['tagAPerson']
                    .map<Widget>((username) => GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ProfileScreen(
                                  username: username,
                                ),
                              ),
                            );
                          },
                          child: Text(
                            '@$username',
                            style: TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ))
                    .toList(),
              ),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        isLiked ? Icons.favorite : Icons.favorite_border,
                        color: isLiked ? Colors.red : null,
                      ),
                      onPressed: _toggleLike,
                    ),
                    Text('${widget.post['like']}'),
                    IconButton(
                      icon: Icon(Icons.comment_outlined),
                      onPressed: () => _showCommentsModal(context),
                    ),
                    Text('${widget.post['comment']}'),
                  ],
                ),
                IconButton(
                  icon: Icon(
                    isRecorded ? Icons.bookmark : Icons.bookmark_border,
                    color: isRecorded ? Colors.blue : null,
                  ),
                  onPressed: _toggleSave,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMediaContent() {
    final List<String> mediaUrls = List<String>.from(widget.post['content'] ?? []);
    
    return Stack(
      children: [
        Container(
          height: 400,
          child: PageView.builder(
            controller: _mediaController,
            onPageChanged: (index) {
              setState(() {
                _currentMediaIndex = index;
              });
            },
            itemCount: mediaUrls.length,
            itemBuilder: (context, index) {
              final String url = mediaUrls[index];
              return GestureDetector(
                onDoubleTap: _handleDoubleTap,
                child: url.toLowerCase().endsWith('.mp4')
                    ? VideoPlayerWidget(url: url)
                    : Image.network(
                        url,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Center(child: Icon(Icons.error));
                        },
                      ),
              );
            },
          ),
        ),
        if (mediaUrls.length > 1)
          Positioned(
            bottom: 10,
            right: 10,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${_currentMediaIndex + 1}/${mediaUrls.length}',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildPopularityScore() {
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withOpacity(0.3),
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.trending_up,
            color: Colors.purple,
            size: 20,
          ),
          SizedBox(width: 4),
          Text(
            'Popülerlik: ${widget.post['popularityScore']}',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  void _showCommentsModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              child: Text(
                'Yorumlar',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                itemCount: comments.length + 1,
                itemBuilder: (context, index) {
                  if (index == comments.length) {
                    return isLoadingComments
                        ? Center(child: CircularProgressIndicator())
                        : SizedBox();
                  }

                  final comment = comments[index];
                  return Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          backgroundImage: NetworkImage(comment.profilePhoto),
                          radius: 20,
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    comment.username,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    comment.howManyMinutesAgo,
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 4),
                              Text(
                                comment.content,
                                style: TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, size: 20),
                          onPressed: () => _deleteComment(comment.id),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _commentController,
                      decoration: InputDecoration(
                        hintText: 'Yorum yaz...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.send),
                    onPressed: _addComment,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);
    if (difference.inDays > 0) {
      return '${difference.inDays} gün önce';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} saat önce';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} dakika önce';
    } else {
      return 'Az önce';
    }
  }
}

class CommentDTO {
  final String id;
  final String username;
  final String profilePhoto;
  final String content;
  final String howManyMinutesAgo;

  CommentDTO({
    required this.id,
    required this.username,
    required this.profilePhoto,
    required this.content,
    required this.howManyMinutesAgo,
  });

  factory CommentDTO.fromJson(Map<String, dynamic> json) {
    return CommentDTO(
      id: json['id']?.toString() ?? '',
      username: json['username'] ?? '',
      profilePhoto: json['profilePhoto'] ?? '',
      content: json['content'] ?? '',
      howManyMinutesAgo: json['howManyMinutesAgo'] ?? '',
    );
  }
}

class PostDTO {
  final String postId;
  final int userId;
  final String username;
  final List<String> content;
  final String profilePhoto;
  final String description;
  final List<String> tagAPerson;
  final String location;
  final DateTime createdAt;
  final String howMoneyMinutesAgo;
  final int like;
  final int comment;
  final int popularityScore;

  PostDTO.fromJson(Map<String, dynamic> json)
      : postId = json['postId'],
        userId = json['userId'],
        username = json['username'],
        content = List<String>.from(json['content']),
        profilePhoto = json['profilePhoto'],
        description = utf8.decode(json['description'].toString().codeUnits),
        tagAPerson = List<String>.from(json['tagAPerson'] ?? []),
        location = json['location'],
        createdAt = DateTime.parse(json['createdAt']),
        howMoneyMinutesAgo = json['howMoneyMinutesAgo'],
        like = json['like'],
        comment = json['comment'],
        popularityScore = json['popularityScore'];
}

class VideoPlayerWidget extends StatefulWidget {
  final String url;

  const VideoPlayerWidget({Key? key, required this.url}) : super(key: key);

  @override
  _VideoPlayerWidgetState createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _videoPlayerController;
  ChewieController? _chewieController;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    try {
      _videoPlayerController = VideoPlayerController.network(widget.url);
      await _videoPlayerController.initialize();
      
      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController,
        aspectRatio: _videoPlayerController.value.aspectRatio,
        autoPlay: false,
        looping: false,
        showControls: true,
        placeholder: Center(child: CircularProgressIndicator()),
        materialProgressColors: ChewieProgressColors(
          playedColor: Colors.blue,
          handleColor: Colors.blueAccent,
          backgroundColor: Colors.grey,
          bufferedColor: Colors.white,
        ),
      );

      setState(() {
        _isInitialized = true;
      });
    } catch (e) {
      print('Video yüklenirken hata: $e');
    }
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _isInitialized
        ? Container(
            height: 400,
            child: Chewie(controller: _chewieController!),
          )
        : Container(
            height: 400,
            child: Center(child: CircularProgressIndicator()),
          );
  }
} 