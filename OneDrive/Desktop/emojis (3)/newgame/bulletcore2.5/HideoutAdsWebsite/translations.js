// Multi-Language Translation System for Space Shooter Website
// Supports: English, Spanish, French, German, Japanese, Chinese, Portuguese, Russian

const translations = {
    en: {
        name: 'English',
        flag: '🇺🇸',
        nav: {
            about: 'About',
            features: 'Features',
            howToPlay: 'How to Play',
            changelog: 'Changelog',
            leaderboard: 'Leaderboard',
            referFriend: 'Refer a Friend',
            reportBug: 'Report Bug',
            signIn: 'Sign In',
            theme: 'Theme'
        },
        hero: {
            title: 'SPACE SHOOTER',
            tagline: '🚀 Epic Space Battles Await 🌌',
            downloadPC: '💻 Download for PC',
            playBrowser: '🌐 Play in Browser'
        },
        sections: {
            aboutTitle: 'About the Game',
            aboutText1: 'Galactic Combat is an intense space shooter where you battle through waves of alien invaders, collect power-ups, and fight massive bosses. Navigate through beautiful space environments including asteroid fields, nebula clouds, ice fields, and debris zones.',
            aboutText2: 'Features 20 unlockable maps, multiple game modes, achievements, daily challenges, and multiplayer battles with up to 32 players!',
            playNowTitle: 'Play Now',
            communityTitle: 'Join Our Community',
            rateGame: 'Rate Our Game!',
            avgRating: 'Average Rating',
            ratings: 'ratings',
            thanksRating: 'Thanks for your rating!'
        },
        community: {
            discord: '💬 Join Discord',
            twitch: '🎥 Watch on Twitch',
            itchio: '🎮 View on Itch.io',
            reportBug: '🐛 Report a Bug',
            donate: '💰 Donate via PayPal'
        },
        auth: {
            signIn: 'Sign In',
            signUp: 'Sign Up',
            guest: 'Guest',
            username: 'Username',
            password: 'Password',
            email: 'Email',
            signInButton: 'Sign In',
            signUpButton: 'Create Account',
            playAsGuest: 'Play as Guest',
            guestName: 'Guest Name',
            backHome: '← Back to Home',
            settings: '⚙️ Settings',
            launchGame: '🎮 Launch Game',
            signOut: '🚪 Sign Out'
        },
        footer: {
            version: 'Version 2.5 Beta',
            developedBy: 'Developed by',
            madeWith: 'Made with 💜 by',
            privacyPolicy: 'Privacy Policy',
            terms: 'Terms of Service',
            faq: 'FAQ',
            controls: 'Controls'
        },
        notifications: {
            welcomeBack: 'Welcome back',
            readyForAction: 'Ready for action',
            goodToSee: 'Good to see you',
            welcomeToGame: 'Welcome to the game',
            autoAuth: "You're automatically authenticated for the game!",
            starterBundle: '🎁 Starter Bundle Received! 1000 Credits + Boosters!',
            referralBonus: '🎁 Referral Bonus: +500 Credits!',
            welcomeDeveloper: 'Welcome, Developer'
        }
    },
    es: {
        name: 'Español',
        flag: '🇪🇸',
        nav: {
            about: 'Acerca de',
            features: 'Características',
            howToPlay: 'Cómo Jugar',
            changelog: 'Registro de Cambios',
            leaderboard: 'Tabla de Líderes',
            referFriend: 'Referir un Amigo',
            reportBug: 'Reportar Error',
            signIn: 'Iniciar Sesión',
            theme: 'Tema'
        },
        hero: {
            title: 'TIRADOR ESPACIAL',
            tagline: '🚀 Te Esperan Batallas Espaciales Épicas 🌌',
            downloadPC: '💻 Descargar para PC',
            playBrowser: '🌐 Jugar en Navegador'
        },
        sections: {
            aboutTitle: 'Sobre el Juego',
            aboutText1: 'Combate Galáctico es un intenso tirador espacial donde luchas contra oleadas de invasores alienígenas, recoges potenciadores y combates jefes masivos. Navega por hermosos entornos espaciales incluyendo campos de asteroides, nubes de nebulosas, campos de hielo y zonas de escombros.',
            aboutText2: '¡Cuenta con 20 mapas desbloqueables, múltiples modos de juego, logros, desafíos diarios y batallas multijugador con hasta 32 jugadores!',
            playNowTitle: 'Jugar Ahora',
            communityTitle: 'Únete a Nuestra Comunidad',
            rateGame: '¡Califica Nuestro Juego!',
            avgRating: 'Calificación Promedio',
            ratings: 'calificaciones',
            thanksRating: '¡Gracias por tu calificación!'
        },
        community: {
            discord: '💬 Unirse a Discord',
            twitch: '🎥 Ver en Twitch',
            itchio: '🎮 Ver en Itch.io',
            reportBug: '🐛 Reportar un Error',
            donate: '💰 Donar vía PayPal'
        },
        auth: {
            signIn: 'Iniciar Sesión',
            signUp: 'Registrarse',
            guest: 'Invitado',
            username: 'Nombre de Usuario',
            password: 'Contraseña',
            email: 'Correo Electrónico',
            signInButton: 'Iniciar Sesión',
            signUpButton: 'Crear Cuenta',
            playAsGuest: 'Jugar como Invitado',
            guestName: 'Nombre de Invitado',
            backHome: '← Volver al Inicio',
            settings: '⚙️ Configuración',
            launchGame: '🎮 Iniciar Juego',
            signOut: '🚪 Cerrar Sesión'
        },
        footer: {
            version: 'Versión 2.5 Beta',
            developedBy: 'Desarrollado por',
            madeWith: 'Hecho con 💜 por',
            privacyPolicy: 'Política de Privacidad',
            terms: 'Términos de Servicio',
            faq: 'Preguntas Frecuentes',
            controls: 'Controles'
        },
        notifications: {
            welcomeBack: 'Bienvenido de nuevo',
            readyForAction: 'Listo para la acción',
            goodToSee: 'Bueno verte',
            welcomeToGame: 'Bienvenido al juego',
            autoAuth: '¡Estás automáticamente autenticado para el juego!',
            starterBundle: '¡Paquete Inicial Recibido! ¡1000 Créditos + Potenciadores!',
            referralBonus: '¡Bonificación por Referencia! ¡+500 Créditos!',
            welcomeDeveloper: 'Bienvenido, Desarrollador'
        }
    },
    fr: {
        name: 'Français',
        flag: '🇫🇷',
        nav: {
            about: 'À Propos',
            features: 'Fonctionnalités',
            howToPlay: 'Comment Jouer',
            changelog: 'Journal des Modifications',
            leaderboard: 'Classement',
            referFriend: 'Parrainer un Ami',
            reportBug: 'Signaler un Bug',
            signIn: 'Se Connecter',
            theme: 'Thème'
        },
        hero: {
            title: 'TIREUR SPATIAL',
            tagline: '🚀 Des Batailles Spatiales Épiques Vous Attendent 🌌',
            downloadPC: '💻 Télécharger pour PC',
            playBrowser: '🌐 Jouer dans le Navigateur'
        },
        sections: {
            aboutTitle: 'À Propos du Jeu',
            aboutText1: 'Galactic Combat est un jeu de tir spatial intense où vous combattez des vagues d\'envahisseurs extraterrestres, collectez des power-ups et affrontez des boss massifs. Naviguez dans de magnifiques environnements spatiaux incluant des champs d\'astéroïdes, des nuages de nébuleuses, des champs de glace et des zones de débris.',
            aboutText2: 'Comprend 20 cartes débloquables, plusieurs modes de jeu, des succès, des défis quotidiens et des batailles multijoueur jusqu\'à 32 joueurs!',
            playNowTitle: 'Jouer Maintenant',
            communityTitle: 'Rejoignez Notre Communauté',
            rateGame: 'Évaluez Notre Jeu!',
            avgRating: 'Note Moyenne',
            ratings: 'évaluations',
            thanksRating: 'Merci pour votre évaluation!'
        },
        community: {
            discord: '💬 Rejoindre Discord',
            twitch: '🎥 Regarder sur Twitch',
            itchio: '🎮 Voir sur Itch.io',
            reportBug: '🐛 Signaler un Bug',
            donate: '💰 Faire un Don via PayPal'
        },
        auth: {
            signIn: 'Se Connecter',
            signUp: 'S\'Inscrire',
            guest: 'Invité',
            username: 'Nom d\'Utilisateur',
            password: 'Mot de Passe',
            email: 'E-mail',
            signInButton: 'Se Connecter',
            signUpButton: 'Créer un Compte',
            playAsGuest: 'Jouer en Invité',
            guestName: 'Nom d\'Invité',
            backHome: '← Retour à l\'Accueil',
            settings: '⚙️ Paramètres',
            launchGame: '🎮 Lancer le Jeu',
            signOut: '🚪 Se Déconnecter'
        },
        footer: {
            version: 'Version 2.5 Bêta',
            developedBy: 'Développé par',
            madeWith: 'Fait avec 💜 par',
            privacyPolicy: 'Politique de Confidentialité',
            terms: 'Conditions d\'Utilisation',
            faq: 'FAQ',
            controls: 'Contrôles'
        },
        notifications: {
            welcomeBack: 'Bon retour',
            readyForAction: 'Prêt pour l\'action',
            goodToSee: 'Content de vous voir',
            welcomeToGame: 'Bienvenue dans le jeu',
            autoAuth: 'Vous êtes automatiquement authentifié pour le jeu!',
            starterBundle: 'Pack de Démarrage Reçu! 1000 Crédits + Boosts!',
            referralBonus: 'Bonus de Parrainage! +500 Crédits!',
            welcomeDeveloper: 'Bienvenue, Développeur'
        }
    },
    de: {
        name: 'Deutsch',
        flag: '🇩🇪',
        nav: {
            about: 'Über',
            features: 'Funktionen',
            howToPlay: 'Wie Spielt Man',
            changelog: 'Änderungsprotokoll',
            leaderboard: 'Bestenliste',
            referFriend: 'Freund Empfehlen',
            reportBug: 'Fehler Melden',
            signIn: 'Anmelden',
            theme: 'Thema'
        },
        hero: {
            title: 'WELTRAUM-SHOOTER',
            tagline: '🚀 Epische Weltraumschlachten Warten 🌌',
            downloadPC: '💻 Für PC Herunterladen',
            playBrowser: '🌐 Im Browser Spielen'
        },
        sections: {
            aboutTitle: 'Über das Spiel',
            aboutText1: 'Galactic Combat ist ein intensiver Weltraum-Shooter, bei dem Sie gegen Wellen außerirdischer Invasoren kämpfen, Power-Ups sammeln und massive Bosse bekämpfen. Navigieren Sie durch wunderschöne Weltraumumgebungen, darunter Asteroidenfelder, Nebelwolken, Eisfelder und Trümmerzo nen.',
            aboutText2: 'Enthält 20 freischaltbare Karten, mehrere Spielmodi, Erfolge, tägliche Herausforderungen und Mehrspieler-Schlachten mit bis zu 32 Spielern!',
            playNowTitle: 'Jetzt Spielen',
            communityTitle: 'Tritt Unserer Community Bei',
            rateGame: 'Bewerte Unser Spiel!',
            avgRating: 'Durchschnittliche Bewertung',
            ratings: 'Bewertungen',
            thanksRating: 'Danke für deine Bewertung!'
        },
        community: {
            discord: '💬 Discord Beitreten',
            twitch: '🎥 Auf Twitch Ansehen',
            itchio: '🎮 Auf Itch.io Ansehen',
            reportBug: '🐛 Fehler Melden',
            donate: '💰 Über PayPal Spenden'
        },
        auth: {
            signIn: 'Anmelden',
            signUp: 'Registrieren',
            guest: 'Gast',
            username: 'Benutzername',
            password: 'Passwort',
            email: 'E-Mail',
            signInButton: 'Anmelden',
            signUpButton: 'Konto Erstellen',
            playAsGuest: 'Als Gast Spielen',
            guestName: 'Gastname',
            backHome: '← Zurück zur Startseite',
            settings: '⚙️ Einstellungen',
            launchGame: '🎮 Spiel Starten',
            signOut: '🚪 Abmelden'
        },
        footer: {
            version: 'Version 2.5 Beta',
            developedBy: 'Entwickelt von',
            madeWith: 'Gemacht mit 💜 von',
            privacyPolicy: 'Datenschutz',
            terms: 'Nutzungsbedingungen',
            faq: 'FAQ',
            controls: 'Steuerung'
        },
        notifications: {
            welcomeBack: 'Willkommen zurück',
            readyForAction: 'Bereit für Action',
            goodToSee: 'Schön dich zu sehen',
            welcomeToGame: 'Willkommen im Spiel',
            autoAuth: 'Sie sind automatisch für das Spiel authentifiziert!',
            starterBundle: 'Starter-Paket Erhalten! 1000 Credits + Booster!',
            referralBonus: 'Empfehlungsbonus! +500 Credits!',
            welcomeDeveloper: 'Willkommen, Entwickler'
        }
    },
    ja: {
        name: '日本語',
        flag: '🇯🇵',
        nav: {
            about: '概要',
            features: '機能',
            howToPlay: '遊び方',
            changelog: '変更履歴',
            leaderboard: 'リーダーボード',
            referFriend: '友達を紹介',
            reportBug: 'バグ報告',
            signIn: 'サインイン',
            theme: 'テーマ'
        },
        hero: {
            title: 'スペースシューター',
            tagline: '🚀 壮大な宇宙戦闘が待っています 🌌',
            downloadPC: '💻 PCにダウンロード',
            playBrowser: '🌐 ブラウザでプレイ'
        },
        sections: {
            aboutTitle: 'ゲームについて',
            aboutText1: 'ギャラクティックコンバットは、エイリアン侵略者の波と戦い、パワーアップを集め、巨大なボスと戦う激しい宇宙シューティングゲームです。小惑星帯、星雲の雲、氷原、がれき地帯など、美しい宇宙環境を航行します。',
            aboutText2: '20のアンロック可能なマップ、複数のゲームモード、実績、デイリーチャレンジ、最大32プレイヤーのマルチプレイヤーバトルを搭載！',
            playNowTitle: '今すぐプレイ',
            communityTitle: 'コミュニティに参加',
            rateGame: 'ゲームを評価！',
            avgRating: '平均評価',
            ratings: '評価',
            thanksRating: '評価ありがとうございます！'
        },
        community: {
            discord: '💬 Discordに参加',
            twitch: '🎥 Twitchで視聴',
            itchio: '🎮 Itch.ioで表示',
            reportBug: '🐛 バグを報告',
            donate: '💰 PayPalで寄付'
        },
        auth: {
            signIn: 'サインイン',
            signUp: '登録',
            guest: 'ゲスト',
            username: 'ユーザー名',
            password: 'パスワード',
            email: 'メールアドレス',
            signInButton: 'サインイン',
            signUpButton: 'アカウント作成',
            playAsGuest: 'ゲストとしてプレイ',
            guestName: 'ゲスト名',
            backHome: '← ホームに戻る',
            settings: '⚙️ 設定',
            launchGame: '🎮 ゲーム起動',
            signOut: '🚪 サインアウト'
        },
        footer: {
            version: 'バージョン 2.5 ベータ',
            developedBy: '開発者',
            madeWith: '💜で作成',
            privacyPolicy: 'プライバシーポリシー',
            terms: '利用規約',
            faq: 'よくある質問',
            controls: '操作方法'
        },
        notifications: {
            welcomeBack: 'お帰りなさい',
            readyForAction: 'アクションの準備完了',
            goodToSee: 'お会いできて嬉しいです',
            welcomeToGame: 'ゲームへようこそ',
            autoAuth: 'ゲームに自動的に認証されました！',
            starterBundle: 'スターターバンドル受領！1000クレジット+ブースター！',
            referralBonus: '紹介ボーナス！+500クレジット！',
            welcomeDeveloper: 'ようこそ、開発者'
        }
    },
    zh: {
        name: '中文',
        flag: '🇨🇳',
        nav: {
            about: '关于',
            features: '功能',
            howToPlay: '游戏方法',
            changelog: '更新日志',
            leaderboard: '排行榜',
            referFriend: '推荐好友',
            reportBug: '报告错误',
            signIn: '登录',
            theme: '主题'
        },
        hero: {
            title: '太空射击',
            tagline: '🚀 史诗般的太空战斗等待着您 🌌',
            downloadPC: '💻 下载PC版',
            playBrowser: '🌐 在浏览器中玩'
        },
        sections: {
            aboutTitle: '关于游戏',
            aboutText1: '银河战斗是一款激烈的太空射击游戏，您需要与外星入侵者的波次作战，收集能量提升，并与巨大的Boss战斗。在美丽的太空环境中航行，包括小行星带、星云、冰原和碎片区。',
            aboutText2: '包含20个可解锁地图、多种游戏模式、成就、每日挑战以及最多32名玩家的多人战斗！',
            playNowTitle: '立即游戏',
            communityTitle: '加入我们的社区',
            rateGame: '为我们的游戏评分！',
            avgRating: '平均评分',
            ratings: '评分',
            thanksRating: '感谢您的评分！'
        },
        community: {
            discord: '💬 加入Discord',
            twitch: '🎥 在Twitch观看',
            itchio: '🎮 在Itch.io查看',
            reportBug: '🐛 报告错误',
            donate: '💰 通过PayPal捐赠'
        },
        auth: {
            signIn: '登录',
            signUp: '注册',
            guest: '访客',
            username: '用户名',
            password: '密码',
            email: '电子邮件',
            signInButton: '登录',
            signUpButton: '创建账户',
            playAsGuest: '作为访客游戏',
            guestName: '访客名称',
            backHome: '← 返回首页',
            settings: '⚙️ 设置',
            launchGame: '🎮 启动游戏',
            signOut: '🚪 退出'
        },
        footer: {
            version: '版本 2.5 测试版',
            developedBy: '开发者',
            madeWith: '用💜制作',
            privacyPolicy: '隐私政策',
            terms: '服务条款',
            faq: '常见问题',
            controls: '操作'
        },
        notifications: {
            welcomeBack: '欢迎回来',
            readyForAction: '准备行动',
            goodToSee: '很高兴见到你',
            welcomeToGame: '欢迎来到游戏',
            autoAuth: '您已自动认证游戏！',
            starterBundle: '新手礼包已收到！1000积分+增强器！',
            referralBonus: '推荐奖励！+500积分！',
            welcomeDeveloper: '欢迎，开发者'
        }
    },
    pt: {
        name: 'Português',
        flag: '🇧🇷',
        nav: {
            about: 'Sobre',
            features: 'Recursos',
            howToPlay: 'Como Jogar',
            changelog: 'Registro de Alterações',
            leaderboard: 'Classificação',
            referFriend: 'Indicar Amigo',
            reportBug: 'Reportar Bug',
            signIn: 'Entrar',
            theme: 'Tema'
        },
        hero: {
            title: 'ATIRADOR ESPACIAL',
            tagline: '🚀 Batalhas Espaciais Épicas Aguardam 🌌',
            downloadPC: '💻 Baixar para PC',
            playBrowser: '🌐 Jogar no Navegador'
        },
        sections: {
            aboutTitle: 'Sobre o Jogo',
            aboutText1: 'Galactic Combat é um intenso jogo de tiro espacial onde você luta contra ondas de invasores alienígenas, coleta power-ups e enfrenta chefes massivos. Navegue por belos ambientes espaciais incluindo campos de asteroides, nuvens de nebulosa, campos de gelo e zonas de destroços.',
            aboutText2: 'Possui 20 mapas desbloqueáveis, vários modos de jogo, conquistas, desafios diários e batalhas multiplayer com até 32 jogadores!',
            playNowTitle: 'Jogar Agora',
            communityTitle: 'Junte-se à Nossa Comunidade',
            rateGame: 'Avalie Nosso Jogo!',
            avgRating: 'Avaliação Média',
            ratings: 'avaliações',
            thanksRating: 'Obrigado pela sua avaliação!'
        },
        community: {
            discord: '💬 Entrar no Discord',
            twitch: '🎥 Assistir na Twitch',
            itchio: '🎮 Ver no Itch.io',
            reportBug: '🐛 Reportar um Bug',
            donate: '💰 Doar via PayPal'
        },
        auth: {
            signIn: 'Entrar',
            signUp: 'Cadastrar',
            guest: 'Convidado',
            username: 'Nome de Usuário',
            password: 'Senha',
            email: 'E-mail',
            signInButton: 'Entrar',
            signUpButton: 'Criar Conta',
            playAsGuest: 'Jogar como Convidado',
            guestName: 'Nome de Convidado',
            backHome: '← Voltar ao Início',
            settings: '⚙️ Configurações',
            launchGame: '🎮 Iniciar Jogo',
            signOut: '🚪 Sair'
        },
        footer: {
            version: 'Versão 2.5 Beta',
            developedBy: 'Desenvolvido por',
            madeWith: 'Feito com 💜 por',
            privacyPolicy: 'Política de Privacidade',
            terms: 'Termos de Serviço',
            faq: 'Perguntas Frequentes',
            controls: 'Controles'
        },
        notifications: {
            welcomeBack: 'Bem-vindo de volta',
            readyForAction: 'Pronto para ação',
            goodToSee: 'Bom te ver',
            welcomeToGame: 'Bem-vindo ao jogo',
            autoAuth: 'Você está automaticamente autenticado para o jogo!',
            starterBundle: 'Pacote Inicial Recebido! 1000 Créditos + Impulsionadores!',
            referralBonus: 'Bônus de Indicação! +500 Créditos!',
            welcomeDeveloper: 'Bem-vindo, Desenvolvedor'
        }
    },
    ru: {
        name: 'Русский',
        flag: '🇷🇺',
        nav: {
            about: 'О нас',
            features: 'Возможности',
            howToPlay: 'Как играть',
            changelog: 'Список изменений',
            leaderboard: 'Таблица лидеров',
            referFriend: 'Пригласить друга',
            reportBug: 'Сообщить об ошибке',
            signIn: 'Войти',
            theme: 'Тема'
        },
        hero: {
            title: 'КОСМИЧЕСКИЙ СТРЕЛОК',
            tagline: '🚀 Эпические космические битвы ждут 🌌',
            downloadPC: '💻 Скачать для ПК',
            playBrowser: '🌐 Играть в браузере'
        },
        sections: {
            aboutTitle: 'О игре',
            aboutText1: 'Galactic Combat - это интенсивный космический шутер, где вы сражаетесь с волнами инопланетных захватчиков, собираете усиления и сражаетесь с массивными боссами. Перемещайтесь по красивым космическим окружениям, включая поля астероидов, облака туманностей, ледяные поля и зоны обломков.',
            aboutText2: 'Включает 20 разблокируемых карт, несколько игровых режимов, достижения, ежедневные испытания и многопользовательские сражения до 32 игроков!',
            playNowTitle: 'Играть сейчас',
            communityTitle: 'Присоединяйтесь к нашему сообществу',
            rateGame: 'Оцените нашу игру!',
            avgRating: 'Средний рейтинг',
            ratings: 'оценок',
            thanksRating: 'Спасибо за вашу оценку!'
        },
        community: {
            discord: '💬 Присоединиться к Discord',
            twitch: '🎥 Смотреть на Twitch',
            itchio: '🎮 Посмотреть на Itch.io',
            reportBug: '🐛 Сообщить об Ошибке',
            donate: '💰 Пожертвовать через PayPal'
        },
        auth: {
            signIn: 'Войти',
            signUp: 'Зарегистрироваться',
            guest: 'Гость',
            username: 'Имя пользователя',
            password: 'Пароль',
            email: 'Электронная почта',
            signInButton: 'Войти',
            signUpButton: 'Создать Аккаунт',
            playAsGuest: 'Играть как Гость',
            guestName: 'Имя Гостя',
            backHome: '← Назад на Главную',
            settings: '⚙️ Настройки',
            launchGame: '🎮 Запустить Игру',
            signOut: '🚪 Выйти'
        },
        footer: {
            version: 'Версия 2.5 Бета',
            developedBy: 'Разработано',
            madeWith: 'Сделано с 💜',
            privacyPolicy: 'Политика Конфиденциальности',
            terms: 'Условия Использования',
            faq: 'Часто Задаваемые Вопросы',
            controls: 'Управление'
        },
        notifications: {
            welcomeBack: 'С возвращением',
            readyForAction: 'Готовы к действию',
            goodToSee: 'Рады вас видеть',
            welcomeToGame: 'Добро пожаловать в игру',
            autoAuth: 'Вы автоматически авторизованы для игры!',
            starterBundle: 'Стартовый Набор Получен! 1000 Кредитов + Усиления!',
            referralBonus: 'Бонус за Приглашение! +500 Кредитов!',
            welcomeDeveloper: 'Добро пожаловать, Разработчик'
        }
    }
};

// Language Manager
const LanguageManager = {
    currentLanguage: localStorage.getItem('selectedLanguage') || 'en',
    
    init() {
        this.applyLanguage(this.currentLanguage);
    },
    
    setLanguage(lang) {
        if (translations[lang]) {
            this.currentLanguage = lang;
            localStorage.setItem('selectedLanguage', lang);
            this.applyLanguage(lang);
            window.location.reload();
        }
    },
    
    applyLanguage(lang) {
        const t = translations[lang] || translations.en;
        document.documentElement.lang = lang;
        
        // Update all translatable elements
        document.querySelectorAll('[data-i18n]').forEach(element => {
            const key = element.getAttribute('data-i18n');
            const keys = key.split('.');
            let value = t;
            
            for (const k of keys) {
                value = value[k];
                if (!value) break;
            }
            
            if (value) {
                if (element.tagName === 'INPUT' && element.placeholder) {
                    element.placeholder = value;
                } else {
                    element.textContent = value;
                }
            }
        });
    },
    
    get(key) {
        const t = translations[this.currentLanguage] || translations.en;
        const keys = key.split('.');
        let value = t;
        
        for (const k of keys) {
            value = value[k];
            if (!value) break;
        }
        
        return value || key;
    }
};

// Initialize language system when DOM is ready
if (typeof window !== 'undefined') {
    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', () => LanguageManager.init());
    } else {
        LanguageManager.init();
    }
}

// Export for use in other scripts
if (typeof module !== 'undefined' && module.exports) {
    module.exports = { translations, LanguageManager };
}
