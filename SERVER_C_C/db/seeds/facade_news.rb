articles = [
  {
    title: "Why Do Cats Knead with Their Paws?",
    marker: 'sBEpxi+ehowBmsvhSnABx+XSdSELfvy1',
    details: {
      introduction: "If you have a cat, you've probably noticed it kneading soft surfaces with its paws. This behavior may seem curious, but it has interesting explanations.",
      content: "Kneading in cats is associated with their nursing stage when they stimulated their mother to get milk. In adulthood, this behavior persists as an act of comfort and well-being. It can also be a way to mark territory since cats have scent glands in their paws that release pheromones.",
      tips: [
        "Don't interrupt your cat when it's kneading; it's a sign of comfort.",
        "Place a soft blanket where it likes to knead to prevent furniture damage.",
        "If it kneads with its claws out, trim them regularly."
      ],
      main_image: "https://example.com/cat_kneading.jpg",
      other_images: ["https://example.com/cat_blanket.jpg", "https://example.com/happy_cat.jpg"],

    },
    crypt_config: {
      key: '94HqLQ9awwfxJqrB3wWTYnLgVGhWF8888ERgky5cWA8=',
      iv: 'AUqX/WWWrzzzFnbo',
    },
    app_link: '',
    active: true,
    published_at: Time.now
  },
  {
    title: "Why Do Cats Sleep So Much?",
    marker: '',
    details: {
      introduction: "Cats are known for sleeping long hours every day. But have you ever wondered why they sleep so much?",
      content: "On average, cats sleep between 12 and 16 hours a day, sometimes even more. This need for sleep comes from their predatory instinct, as felines in the wild need to conserve energy for hunting. Additionally, their metabolism and growth process require long periods of rest.",
      tips: [
        "Respect your cat’s sleep schedule; don’t wake it up unnecessarily.",
        "Provide a comfortable bed in a quiet place.",
        "If you notice drastic changes in its sleep patterns, consult a veterinarian."
      ],
      main_image: "https://example.com/cat_sleeping.jpg",
      other_images: ["https://example.com/cat_bed.jpg"]
    }
  },
  {
    title: "The Mystery Behind Cat Purring",
    marker: '',
    details: {
      introduction: "Purring is one of the most characteristic and fascinating sounds of cats. It is associated with well-being, but it also has other meanings.",
      content: "Cats purr when they are happy, but also when they are in pain or stressed. It is believed that purring has therapeutic properties. The vibrations from purring can help calm the cat and aid in recovery during illness or anxiety.",
      tips: [
        "If your cat purrs while you pet it, enjoy the moment—it's a sign of happiness.",
        "If it purrs in stressful situations, try to calm it with gentle strokes and a quiet environment.",
        "If purring is accompanied by signs of illness, visit the veterinarian."
      ],
      main_image: "https://example.com/cat_purring.jpg",
      other_images: ["https://example.com/relaxed_cat.jpg"]
    }
  },
  {
    title: "How to Understand Your Cat’s Body Language?",
    marker: '',
    details: {
      introduction: "Cats have a unique way of communicating with their surroundings and their owners through body language.",
      content: "Forward-facing ears indicate curiosity, while flattened or backward ears can signal fear or aggression. A raised tail generally expresses confidence and happiness, while a puffed-up tail indicates fear. Half-closed eyes can be a sign of relaxation and affection.",
      tips: [
        "Observe the position of the ears and tail to understand your cat’s mood.",
        "If it blinks slowly at you, return the gesture—it's a way of saying 'I love you.'",
        "Avoid forcing contact if you notice signs of discomfort in its posture."
      ],
      main_image: "https://example.com/cat_bodylanguage.jpg",
      other_images: ["https://example.com/cat_happy_tail.jpg"]
    }
  },
  {
    title: "Tips for a Healthy Cat Diet",
    marker: '',
    details: {
      introduction: "Nutrition is a key aspect of your cat’s health and well-being. A balanced diet is essential for its content.",
      content: "Cats are obligate carnivores, meaning they need animal protein to get essential nutrients. It's important to offer high-quality food, whether dry kibble or wet food, and avoid dangerous foods like chocolate, onions, or garlic.",
      tips: [
        "Consult a veterinarian to choose the best diet based on your cat’s age and health condition.",
        "Avoid giving it human food unless you’re sure it's safe for cats.",
        "Always provide fresh, clean water."
      ],
      main_image: "https://example.com/cat_eating.jpg",
      other_images: ["https://example.com/cat_bowl.jpg", "https://example.com/cat_drinking.jpg"]
    }
  }
]

articles.each do |e|
  m = FacadeNew.find_or_initialize_by(title: e[:title])
  m.assign_attributes(
    marker: e[:marker],
    details: e[:details],
    crypt_config: e[:crypt_config] || {},
    app_link: e[:app_link],
    active: e[:active] || false,
    published_at: e[:published_at]
  )

  m.save!
end