import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/community_provider.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  final TextEditingController _newPostController = TextEditingController();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Provider.of<CommunityProvider>(context, listen: false).fetchPosts();
      }
    });
  }

  @override
  void dispose() {
    _newPostController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final communityProvider = Provider.of<CommunityProvider>(context);
    final posts = communityProvider.posts;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF4CAF50).withValues(alpha: 0.1),
            Colors.white,
          ],
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // --- Header ---
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 20),
                  _buildCommunityStats(),
                  const SizedBox(height: 24),
                  _buildSectionTitle(),
                ],
              ),
            ),

            // --- Input para nueva publicación ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _newPostController,
                      decoration: InputDecoration(
                        hintText: '¿Qué quieres compartir?',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () async {
                      final content = _newPostController.text.trim();
                      if (content.isNotEmpty) {
                        await communityProvider.createPost(
                          userId: '123', // Reemplaza con el ID real del usuario
                          message:
                              content, // <-- cambia "contenido" a "message"
                        );
                        _newPostController.clear();
                        await communityProvider
                            .fetchPosts(); // refresca la lista
                      }
                    },
                    child: const Text('Publicar'),
                  ),
                ],
              ),
            ),

            // --- Lista de publicaciones ---
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async => await communityProvider.fetchPosts(),
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: posts.length,
                  itemBuilder: (context, index) {
                    final post = posts[index];
                    return _buildPostCard(
                      context: context,
                      user: post['User']?['email'] ?? 'Anónimo',
                      avatar:
                          post['User']?['email']
                              ?.substring(0, 1)
                              .toUpperCase() ??
                          'U',
                      text: post['message'] ?? '',
                      time: post['createdAt'] != null
                          ? DateTime.parse(
                              post['createdAt'],
                            ).toLocal().toIso8601String().split('T')[0]
                          : 'Reciente',
                      likes: (post['likes'] ?? 0).toString(),
                      comments: ((post['comentarios'] ?? []) as List).length
                          .toString(),
                      achievement: 'Participante',
                      color: const Color(0xFF4CAF50),
                      onLike: () => communityProvider.likePost(post['id']),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ------------------ COMPONENTES ------------------

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF9C27B0), Color(0xFFBA68C8)],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF9C27B0).withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(
            Icons.people_rounded,
            color: Colors.white,
            size: 28,
          ),
        ),
        const SizedBox(width: 16),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Comunidad',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2E7D32),
                ),
              ),
              Text(
                'Inspírate con otros',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCommunityStats() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF9C27B0), Color(0xFFBA68C8)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF9C27B0).withValues(alpha: 0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildCommunityStatItem(
              icon: Icons.people_rounded,
              value: '1,234',
              label: 'Miembros',
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: Colors.white.withValues(alpha: 0.3),
          ),
          Expanded(
            child: _buildCommunityStatItem(
              icon: Icons.eco_rounded,
              value: '5,678',
              label: 'Retos completados',
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: Colors.white.withValues(alpha: 0.3),
          ),
          Expanded(
            child: _buildCommunityStatItem(
              icon: Icons.public_rounded,
              value: '12.5T',
              label: 'CO₂ ahorrado',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommunityStatItem({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 11,
            color: Colors.white.withValues(alpha: 0.9),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Últimas publicaciones',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2E7D32),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFF4CAF50).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Row(
            children: [
              Icon(
                Icons.fiber_manual_record_rounded,
                size: 8,
                color: Color(0xFF4CAF50),
              ),
              SizedBox(width: 6),
              Text(
                'En vivo',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF4CAF50),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPostCard({
    required BuildContext context,
    required String user,
    required String avatar,
    required String text,
    required String time,
    required String likes,
    required String comments,
    required String achievement,
    required Color color,
    required VoidCallback onLike,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- Header del post ---
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [color, color.withValues(alpha: 0.7)],
                    ),
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: color.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      avatar,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2E7D32),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.emoji_events_rounded,
                            size: 14,
                            color: color,
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              achievement,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: color,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Text(
                  time,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                ),
              ],
            ),
          ),

          // --- Contenido ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              text,
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey.shade800,
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // --- Botones ---
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                _buildActionButton(
                  icon: Icons.favorite_rounded,
                  label: likes.toString(),
                  color: Colors.red,
                  onTap: onLike,
                ),
                const SizedBox(width: 20),
                _buildActionButton(
                  icon: Icons.chat_bubble_rounded,
                  label: comments.toString(),
                  color: const Color(0xFF2196F3),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Funcionalidad de comentarios próximamente',
                        ),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                ),
                const Spacer(),
                _buildActionButton(
                  icon: Icons.share_rounded,
                  label: 'Compartir',
                  color: const Color(0xFF4CAF50),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Compartiendo...'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
