import '../models/journey_models.dart';

class PlaceholderDataService {
  static List<Journey> getJourneys() {
    return [
      Journey(
        id: 'data_structures_algorithms',
        title: 'Data Structures & Algorithms',
        category: 'Computer Science',
        description: 'Master the fundamentals of computer science through engaging conversations and hands-on practice.',
        episodeIds: ['dsa_1', 'dsa_2', 'dsa_3', 'dsa_4', 'dsa_5', 'dsa_6'],
        totalDuration: 2520, // 42 minutes in seconds
        iconName: 'code',
        colorHex: '#FF6B6B',
      ),
      Journey(
        id: 'science_mysteries',
        title: 'Science Mysteries & Discoveries',
        category: 'Science',
        description: 'Explore the fascinating mysteries of our universe and groundbreaking scientific discoveries.',
        episodeIds: ['science_1', 'science_2', 'science_3', 'science_4', 'science_5'],
        totalDuration: 2400, // 40 minutes in seconds
        iconName: 'science',
        colorHex: '#4ECDC4',
      ),
      Journey(
        id: 'psychology',
        title: 'Psychology & Human Behavior',
        category: 'Psychology',
        description: 'Discover the fascinating world of human psychology and understand what drives our behavior.',
        episodeIds: ['psychology_1', 'psychology_2', 'psychology_3', 'psychology_4', 'psychology_5'],
        totalDuration: 2400, // 40 minutes in seconds
        iconName: 'psychology',
        colorHex: '#45B7D1',
      ),
      Journey(
        id: 'personal_finance',
        title: 'Personal Finance Mastery',
        category: 'Finance',
        description: 'Build a strong financial foundation with practical money management skills.',
        episodeIds: ['finance_1', 'finance_2', 'finance_3', 'finance_4', 'finance_5'],
        totalDuration: 2100, // 35 minutes in seconds
        iconName: 'finance',
        colorHex: '#96CEB4',
      ),
    ];
  }

  static List<Episode> getAllEpisodes() {
    return [
      // DSA Episodes
      Episode(
        id: 'dsa_1',
        journeyId: 'data_structures_algorithms',
        title: 'Understanding Arrays & Their Magic',
        description: 'Discover how arrays work and why they\'re fundamental to programming.',
        audioUrl: 'dsa/episode_1_conversational.mp3',
        duration: 420, // 7 minutes in seconds
        order: 1,
        transcript: 'Arrays are the foundation of data structures...',
        keyPoints: ['Array basics', 'Memory allocation', 'Time complexity'],
      ),
      Episode(
        id: 'dsa_2',
        journeyId: 'data_structures_algorithms',
        title: 'Linked Lists: Building Chains of Data',
        description: 'Learn how linked lists connect data in flexible ways.',
        audioUrl: 'dsa/episode_2_conversational.mp3',
        duration: 420, // 7 minutes in seconds
        order: 2,
        transcript: 'Linked lists provide dynamic memory allocation...',
        keyPoints: ['Node structure', 'Pointer concepts', 'Dynamic allocation'],
      ),
      Episode(
        id: 'dsa_3',
        journeyId: 'data_structures_algorithms',
        title: 'Stacks & Queues: Order Matters',
        description: 'Understand how stacks and queues manage data order.',
        audioUrl: 'dsa/episode_3_conversational.mp3',
        duration: 420, // 7 minutes in seconds
        order: 3,
        transcript: 'Stacks follow LIFO while queues follow FIFO...',
        keyPoints: ['LIFO principle', 'FIFO principle', 'Real-world applications'],
      ),
      Episode(
        id: 'dsa_4',
        journeyId: 'data_structures_algorithms',
        title: 'Trees: Branching Out Your Data',
        description: 'Explore how tree structures organize information hierarchically.',
        audioUrl: 'dsa/episode_4_conversational.mp3',
        duration: 420, // 7 minutes in seconds
        order: 4,
        transcript: 'Trees provide hierarchical data organization...',
        keyPoints: ['Tree terminology', 'Binary trees', 'Tree traversal'],
      ),
      Episode(
        id: 'dsa_5',
        journeyId: 'data_structures_algorithms',
        title: 'Hash Tables: Lightning Fast Lookups',
        description: 'Discover the power of hash tables for quick data retrieval.',
        audioUrl: 'dsa/episode_5_conversational.mp3',
        duration: 420, // 7 minutes in seconds
        order: 5,
        transcript: 'Hash tables provide O(1) average lookup time...',
        keyPoints: ['Hash functions', 'Collision handling', 'Performance benefits'],
      ),
      Episode(
        id: 'dsa_6',
        journeyId: 'data_structures_algorithms',
        title: 'Sorting Algorithms: Bringing Order to Chaos',
        description: 'Learn how different sorting algorithms organize data efficiently.',
        audioUrl: 'dsa/episode_6_conversational.mp3',
        duration: 420, // 7 minutes in seconds
        order: 6,
        transcript: 'Sorting algorithms range from simple to sophisticated...',
        keyPoints: ['Bubble sort', 'Quick sort', 'Time complexity comparison'],
      ),

      // Science Episodes
      Episode(
        id: 'science_1',
        journeyId: 'science_mysteries',
        title: 'Quantum Physics: The Strange World of the Very Small',
        description: 'Explore the mind-bending world of quantum mechanics and particle behavior.',
        audioUrl: 'science_mysteries/episode_1_conversational.mp3',
        duration: 480, // 8 minutes in seconds
        order: 1,
        transcript: 'Quantum physics reveals the strange behavior of particles...',
        keyPoints: ['Wave-particle duality', 'Quantum entanglement', 'Uncertainty principle'],
      ),
      Episode(
        id: 'science_2',
        journeyId: 'science_mysteries',
        title: 'Black Holes: The Universe\'s Ultimate Mystery',
        description: 'Journey into the cosmic phenomena that bend space and time.',
        audioUrl: 'science_mysteries/episode_2_conversational.mp3',
        duration: 480, // 8 minutes in seconds
        order: 2,
        transcript: 'Black holes are regions where gravity is so strong...',
        keyPoints: ['Event horizon', 'Hawking radiation', 'Spacetime curvature'],
      ),
      Episode(
        id: 'science_3',
        journeyId: 'science_mysteries',
        title: 'Ocean Mysteries: Secrets of the Deep',
        description: 'Dive into the unexplored depths of our planet\'s oceans.',
        audioUrl: 'science_mysteries/episode_3_conversational.mp3',
        duration: 480, // 8 minutes in seconds
        order: 3,
        transcript: 'Our oceans remain largely unexplored mysteries...',
        keyPoints: ['Deep sea creatures', 'Ocean currents', 'Underwater ecosystems'],
      ),
      Episode(
        id: 'science_4',
        journeyId: 'science_mysteries',
        title: 'The Human Brain: Consciousness and Memory',
        description: 'Unravel the mysteries of consciousness and how memories form.',
        audioUrl: 'science_mysteries/episode_4_conversational.mp3',
        duration: 480, // 8 minutes in seconds
        order: 4,
        transcript: 'The human brain remains our greatest mystery...',
        keyPoints: ['Neural networks', 'Memory formation', 'Consciousness theories'],
      ),
      Episode(
        id: 'science_5',
        journeyId: 'science_mysteries',
        title: 'Evolution in Action: Life\'s Greatest Experiment',
        description: 'Witness evolution\'s ongoing experiments in adaptation and survival.',
        audioUrl: 'science_mysteries/episode_5_conversational.mp3',
        duration: 480, // 8 minutes in seconds
        order: 5,
        transcript: 'Evolution continues to shape life on Earth...',
        keyPoints: ['Natural selection', 'Genetic variation', 'Adaptation mechanisms'],
      ),

      // Psychology Episodes
      Episode(
        id: 'psychology_1',
        journeyId: 'psychology',
        title: 'Why We Make Bad Decisions',
        description: 'Explore the cognitive biases and mental shortcuts that lead us astray.',
        audioUrl: 'psychology/episode_1_conversational.mp3',
        duration: 480, // 8 minutes in seconds
        order: 1,
        transcript: 'Our brains use shortcuts that sometimes lead us astray...',
        keyPoints: ['Cognitive biases', 'Heuristics', 'Decision-making errors'],
      ),
      Episode(
        id: 'psychology_2',
        journeyId: 'psychology',
        title: 'The Psychology of Procrastination',
        description: 'Understand why we delay and how to overcome the procrastination trap.',
        audioUrl: 'psychology/episode_2_conversational.mp3',
        duration: 480, // 8 minutes in seconds
        order: 2,
        transcript: 'Procrastination is more than just being lazy...',
        keyPoints: ['Temporal discounting', 'Task aversion', 'Overcoming strategies'],
      ),
      Episode(
        id: 'psychology_3',
        journeyId: 'psychology',
        title: 'How Beliefs Shape Reality',
        description: 'Discover how our beliefs influence perception and behavior.',
        audioUrl: 'psychology/episode_3_conversational.mp3',
        duration: 480, // 8 minutes in seconds
        order: 3,
        transcript: 'Our beliefs act as filters for reality...',
        keyPoints: ['Confirmation bias', 'Belief formation', 'Reality perception'],
      ),
      Episode(
        id: 'psychology_4',
        journeyId: 'psychology',
        title: 'The Science of Relationships',
        description: 'Explore what psychology reveals about human connections and love.',
        audioUrl: 'psychology/episode_4_conversational.mp3',
        duration: 480, // 8 minutes in seconds
        order: 4,
        transcript: 'Human relationships follow psychological patterns...',
        keyPoints: ['Attachment styles', 'Love psychology', 'Social bonding'],
      ),
      Episode(
        id: 'psychology_5',
        journeyId: 'psychology',
        title: 'Building Better Habits',
        description: 'Learn the psychology behind habit formation and behavior change.',
        audioUrl: 'psychology/episode_5_conversational.mp3',
        duration: 480, // 8 minutes in seconds
        order: 5,
        transcript: 'Habits form through repetition and reinforcement...',
        keyPoints: ['Habit loop', 'Behavioral change', 'Neural pathways'],
      ),

      // Finance Episodes
      Episode(
        id: 'finance_1',
        journeyId: 'personal_finance',
        title: 'Money Mindset: Your Relationship with Money',
        description: 'Discover how your beliefs about money impact your financial decisions.',
        audioUrl: 'finance/episode_1_conversational.mp3',
        duration: 420, // 7 minutes in seconds
        order: 1,
        transcript: 'Your relationship with money shapes your financial future...',
        keyPoints: ['Money psychology', 'Financial beliefs', 'Mindset shifts'],
      ),
      Episode(
        id: 'finance_2',
        journeyId: 'personal_finance',
        title: 'Budgeting Made Simple',
        description: 'Learn practical budgeting strategies that actually work.',
        audioUrl: 'finance/episode_2_conversational.mp3',
        duration: 420, // 7 minutes in seconds
        order: 2,
        transcript: 'Budgeting is about controlling your money flow...',
        keyPoints: ['Budget categories', 'Tracking expenses', 'Financial planning'],
      ),
      Episode(
        id: 'finance_3',
        journeyId: 'personal_finance',
        title: 'Emergency Funds: Your Financial Safety Net',
        description: 'Build a solid emergency fund to protect your financial future.',
        audioUrl: 'finance/episode_3_conversational.mp3',
        duration: 420, // 7 minutes in seconds
        order: 3,
        transcript: 'Emergency funds provide financial security...',
        keyPoints: ['Emergency planning', 'Savings strategies', 'Risk management'],
      ),
      Episode(
        id: 'finance_4',
        journeyId: 'personal_finance',
        title: 'Investing Basics: Growing Your Money',
        description: 'Start your investment journey with confidence and knowledge.',
        audioUrl: 'finance/episode_4_conversational.mp3',
        duration: 420, // 7 minutes in seconds
        order: 4,
        transcript: 'Investing helps your money grow over time...',
        keyPoints: ['Investment types', 'Risk vs return', 'Portfolio basics'],
      ),
      Episode(
        id: 'finance_5',
        journeyId: 'personal_finance',
        title: 'Debt Management Strategies',
        description: 'Master effective strategies to eliminate debt and stay debt-free.',
        audioUrl: 'finance/episode_5_conversational.mp3',
        duration: 420, // 7 minutes in seconds
        order: 5,
        transcript: 'Debt management requires strategy and discipline...',
        keyPoints: ['Debt types', 'Payoff strategies', 'Financial freedom'],
      ),
    ];
  }

  static Journey? getJourneyById(String id) {
    try {
      return getJourneys().firstWhere((journey) => journey.id == id);
    } catch (e) {
      return null;
    }
  }

  static Episode? getEpisodeById(String episodeId) {
    try {
      return getAllEpisodes().firstWhere((episode) => episode.id == episodeId);
    } catch (e) {
      return null;
    }
  }

  static List<Episode> getEpisodesByJourneyId(String journeyId) {
    return getAllEpisodes().where((episode) => episode.journeyId == journeyId).toList();
  }
}
