defaults write -g NSAutomaticSpellingCorrectionEnabled -bool false
defaults write -g ApplePressAndHoldEnabled -bool false
sudo defaults write com.apple.universalaccess reduceMotion -bool true
sudo defaults write com.apple.universalaccess reduceTransparency -bool true

defaults write -g KeyRepeat -int 2
defaults write -g InitialKeyRepeat -int 15



# show Library folder
chflags nohidden ~/Library

# show hidden files
defaults write com.apple.finder AppleShowAllFiles YES

# add pathbar to title
defaults write com.apple.finder _FXShowPosixPathInTitle -bool true
