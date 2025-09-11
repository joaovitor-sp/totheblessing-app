import 'package:flutter/material.dart';
import 'package:totheblessing/models/group_model.dart';

class GroupCardWidget extends StatelessWidget {
  final GroupModel group;
  final VoidCallback? onTap; // opcional para clicar no card

  const GroupCardWidget({super.key, required this.group, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 4,
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Imagem do grupo
            Container(
              height: 150,
              decoration: BoxDecoration(
                image: group.imageUrl != null && group.imageUrl!.isNotEmpty
                    ? DecorationImage(
                        image: NetworkImage(group.imageUrl!),
                        fit: BoxFit.cover,
                      )
                    : const DecorationImage(
                        image: AssetImage("assets/images/default_calendar_image.png"),
                        fit: BoxFit.cover,
                      ),
              ),
            ),

            // Conteúdo do card
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    group.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),

                  // Content
                  if (group.content != null && group.content!.isNotEmpty)
                    Text(
                      group.content!,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),

                  const SizedBox(height: 10),

                  // Membros e data de criação
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "${group.members.length} membros",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      if (group.createdAt != null)
                        Text(
                          "${group.createdAt!.day}/${group.createdAt!.month}/${group.createdAt!.year}",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
