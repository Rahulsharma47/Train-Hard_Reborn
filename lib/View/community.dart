import 'package:flutter/material.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: const Color(0xFFF5F5F7),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text('Community', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600)),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.black87),
            onPressed: () {
              // Navigate to search screen
            },
          ),
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.black87),
            onPressed: () {
              // Navigate to notifications screen
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Theme.of(context).primaryColor,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Theme.of(context).primaryColor,
          tabs: const [
            Tab(text: 'Feed'),
            Tab(text: 'Groups'),
            Tab(text: 'Challenges'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildFeedTab(),
          _buildGroupsTab(),
          _buildChallengesTab(),
          SizedBox(height: 90),
        ],
      ),
    );
  }

  Widget _buildFeedTab() {
    // Sample feed data
    final posts = [
      {
        'username': 'sarah_fit',
        'userImage': 'https://i.pravatar.cc/150?img=1',
        'timeAgo': '10 min ago',
        'content': 'Just completed my first 10K run! So proud of my progress this month 🏃‍♀️',
        'image': 'https://i.pravatar.cc/400?img=11',
        'likes': 42,
        'comments': 8,
        'isLiked': true,
      },
      {
        'username': 'mike_strong',
        'userImage': 'https://i.pravatar.cc/150?img=3',
        'timeAgo': '45 min ago',
        'content': 'New personal best on bench press today: 225 lbs x 5 reps! What are your fitness goals this week?',
        'image': '',
        'likes': 36,
        'comments': 15,
        'isLiked': false,
      },
      {
        'username': 'fitness_coach_emma',
        'userImage': 'https://i.pravatar.cc/150?img=5',
        'timeAgo': '2 hours ago',
        'content': 'Sharing my go-to post-workout smoothie recipe: 1 banana, 1 cup berries, 2 tbsp protein powder, 1 cup almond milk, 1 tbsp chia seeds. Blend and enjoy! #PostWorkoutNutrition',
        'image': 'https://i.pravatar.cc/400?img=22',
        'likes': 89,
        'comments': 12,
        'isLiked': true,
      },
    ];

    return ListView.builder(
      padding: const EdgeInsets.only(top: 10),
      itemCount: posts.length,
      itemBuilder: (context, index) {
        final post = posts[index];
        return _buildPostCard(post);
      },
    );
  }

  Widget _buildPostCard(Map<String, dynamic> post) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Post header with user info
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundImage: NetworkImage(post['userImage']),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post['username'],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        post['timeAgo'],
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.more_horiz),
                  onPressed: () {},
                ),
              ],
            ),
          ),

          // Post content
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
            child: Text(
              post['content'],
              style: const TextStyle(fontSize: 15),
            ),
          ),

          // Post image if available
          if (post['image'].isNotEmpty)
            Container(
              width: double.infinity,
              height: 250,
              margin: const EdgeInsets.only(top: 10),
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(post['image']),
                  fit: BoxFit.cover,
                ),
              ),
            ),

          // Post actions
          Padding(
            padding: const EdgeInsets.all(15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      post['isLiked'] ? Icons.favorite : Icons.favorite_border,
                      color: post['isLiked'] ? Colors.red : Colors.grey,
                      size: 20,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      '${post['likes']}',
                      style: TextStyle(
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Icon(
                      Icons.chat_bubble_outline,
                      color: Colors.grey,
                      size: 20,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      '${post['comments']}',
                      style: TextStyle(
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
                const Icon(
                  Icons.share_outlined,
                  color: Colors.grey,
                  size: 20,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGroupsTab() {
    // Sample groups data with valid image URLs
    final groups = [
      {
        'name': 'Morning Runners Club',
        'image': 'https://i.pravatar.cc/400?img=33',
        'members': 1245,
        'isJoined': true,
      },
      {
        'name': 'Weightlifting Enthusiasts',
        'image': 'https://i.pravatar.cc/400?img=44',
        'members': 3782,
        'isJoined': false,
      },
      {
        'name': 'Yoga for Beginners',
        'image': 'https://i.pravatar.cc/400?img=55',
        'members': 952,
        'isJoined': true,
      },
      {
        'name': 'Nutrition & Meal Prep',
        'image': 'https://i.pravatar.cc/400?img=66',
        'members': 2518,
        'isJoined': false,
      },
      {
        'name': 'HIIT Workout Squad',
        'image': 'https://i.pravatar.cc/400?img=33', // Fixed image URL
        'members': 1836,
        'isJoined': true,
      },
    ];

    return Column(
      children: [
        // Featured groups section
        Container(
          width: double.infinity,
          margin: const EdgeInsets.all(15),
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue[700]!, Colors.blue[300]!],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Featured Groups',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                'Connect with others who share your fitness interests',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 15),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.blue[700],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
                child: const Text('Explore Featured'),
              ),
            ],
          ),
        ),

        // Groups list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.only(bottom: 15),
            itemCount: groups.length,
            itemBuilder: (context, index) {
              final group = groups[index];
              return _buildGroupCard(group);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildGroupCard(Map<String, dynamic> group) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // Group image
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(15),
              bottomLeft: Radius.circular(15),
            ),
            child: Image.network(
              group['image'],
              width: 100,
              height: 100,
              fit: BoxFit.cover,
            ),
          ),
          
          // Group info - Fix overflow by wrapping in Expanded
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    group['name'],
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    overflow: TextOverflow.ellipsis, // Handle text overflow
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '${group['members']} members',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Make button width responsive
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: group['isJoined'] ? Colors.grey[200] : Theme.of(context).primaryColor,
                        foregroundColor: group['isJoined'] ? Colors.black87 : Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                      ),
                      child: Text(group['isJoined'] ? 'Joined' : 'Join'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChallengesTab() {
    // Sample challenges data with valid image URLs
    final challenges = [
      {
        'title': '30 Days Plank Challenge',
        'image': 'https://i.pravatar.cc/400?img=11', // Fixed image URL
        'participants': 2547,
        'days': 30,
        'progress': 0.7,
        'isJoined': true,
      },
      {
        'title': '10K Steps Daily',
        'image': 'https://i.pravatar.cc/400?img=22', // Fixed image URL
        'participants': 8452,
        'days': 21,
        'progress': 0.5,
        'isJoined': true,
      },
      {
        'title': 'Weight Loss Challenge',
        'image': 'https://i.pravatar.cc/400?img=65',
        'participants': 3861,
        'days': 60,
        'progress': 0.0,
        'isJoined': false,
      },
      {
        'title': 'Hydration Challenge',
        'image': 'https://i.pravatar.cc/400?img=23',
        'participants': 5233,
        'days': 14,
        'progress': 0.3,
        'isJoined': true,
      },
    ];

    return SingleChildScrollView(
      child: Column(
        children: [
          // Featured challenge
          Container(
            margin: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.indigo[800],
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Challenge image
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(15),
                    topRight: Radius.circular(15),
                  ),
                  child: Image.network(
                    'https://i.pravatar.cc/400?img=12',
                    width: double.infinity,
                    height: 150,
                    fit: BoxFit.cover,
                  ),
                ),
                
                // Challenge info
                Padding(
                  padding: const EdgeInsets.all(15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.amber,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'FEATURED',
                          style: TextStyle(
                            color: Colors.black87,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Summer Full Body Challenge',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'Complete daily workouts for 21 days and transform your body',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 15),
                      // Fix potential overflow in Row by using Flexible
                      Row(
                        children: [
                          Icon(Icons.people, color: Colors.white.withOpacity(0.9), size: 18),
                          const SizedBox(width: 5),
                          Flexible(
                            child: Text(
                              '12,846 participants',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 14,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 15),
                          Icon(Icons.calendar_today, color: Colors.white.withOpacity(0.9), size: 18),
                          const SizedBox(width: 5),
                          Text(
                            '21 days',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.indigo[800],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          minimumSize: const Size(double.infinity, 45),
                        ),
                        child: const Text(
                          'Join Challenge',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Active challenges section
          Padding(
            padding: const EdgeInsets.only(left: 15, right: 15, top: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Active Challenges',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text('See All'),
                ),
              ],
            ),
          ),

          // Challenge cards
          ...challenges.map((challenge) => _buildChallengeCard(challenge)).toList(),
        ],
      ),
    );
  }

  Widget _buildChallengeCard(Map<String, dynamic> challenge) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          // Challenge header with image and overlay
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(15),
                  topRight: Radius.circular(15),
                ),
                child: Image.network(
                  challenge['image'],
                  width: double.infinity,
                  height: 120,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.7),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 10,
                left: 15,
                child: Text(
                  challenge['title'],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          // Challenge info
          Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              children: [
                // Stats row with Flexible to prevent overflow
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Row(
                        children: [
                          const Icon(Icons.people, color: Colors.grey, size: 18),
                          const SizedBox(width: 5),
                          Flexible(
                            child: Text(
                              '${challenge['participants']} participants',
                              style: TextStyle(
                                color: Colors.grey[700],
                                fontSize: 14,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today, color: Colors.grey, size: 18),
                        const SizedBox(width: 5),
                        Text(
                          '${challenge['days']} days',
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 15),

                // Progress bar if joined
                if (challenge['isJoined'])
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Your progress',
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            '${(challenge['progress'] * 100).toInt()}%',
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: challenge['progress'],
                        backgroundColor: Colors.grey[200],
                        valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
                        minHeight: 6,
                        borderRadius: BorderRadius.circular(3),
                      ),
                      const SizedBox(height: 15),
                    ],
                  ),

                // Action button
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: challenge['isJoined'] 
                        ? Colors.grey[200] 
                        : Theme.of(context).primaryColor,
                    foregroundColor: challenge['isJoined'] 
                        ? Theme.of(context).primaryColor 
                        : Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    minimumSize: const Size(double.infinity, 45),
                  ),
                  child: Text(
                    challenge['isJoined'] ? 'Continue Challenge' : 'Join Challenge',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}