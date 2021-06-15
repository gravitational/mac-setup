#!/bin/bash

#This script can setup and keep a mac configured according to the desired settings


main() {
	install-xcode #dependency
	install-brew-cask-apps  #installs cli and gui apps
	create-ssh-key #sets up id_rsa and ssh config for first time
	mac-defaults #sets up many mac defaults
}

install-xcode() {
	if test ! $(which xcode-select ); then
		echo "Installing xcode-stuff"
		xcode-select --install
	else 
		echo "xcode-select already installed"
	fi
}


install-brew-cask-apps() {
	if test ! $(which brew); then

		echo "Installing homebrew..."
		ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
	else
		echo "homebrew already installed"

	fi

	echo "Updating homebrew..."
	brew update


	if test  $(which brew) ;then

		echo "Installing homebrew apps ..."

		apps=(
			coreutils #make mac command line more like GNU Linux
			git
			git-extras
			legit
			git-flow
			tree
			wget
			cask
			expect
			python
		)

			for i in "${apps[@]}" ;do
				if test ! $(which "$i") ;then
					echo "installing $i"
					brew  install $i
				else
					echo " brew app $i already installed"
				fi
			done
	fi

	#is this necesaary?
	echo "Cleaning up brew"
	brew cleanup


	#GUI Application install using brew cask
	if test $(which cask); then

		apps=(
			#browsers
			google-chrome # work browser
			firefox  # personl browser
			

			#Teleport Apps
			zoomus
			1password
			slack
			google-backup-and-sync
			
			#dev
			drone-cli
			docker
			visual-studio-code
			postman
			
			#vpn
			protonvpn

			#chat
			signal

			#mac productivity
			alfred # Improved Search
			bettertouchtool #Window Snapping and touchpad gestures, hotkey

			#fun
			spotify
			vlc
			transmission

		)

		echo "installing brew cask apps ..."

			for i in "${apps[@]}" ; do
				if [ ! -e /usr/local/Caskroom/$i ] 
				then
					echo "installing $i"
					brew install --cask $i
				else 
					echo "brew cask app $i already installed"
				fi
			done

		brew cleanup
	fi
}

create-ssh-key() {
	read -p "Create SSH Key? " -n 1 -r
	echo    # (optional) move to a new line
	if [[ $REPLY =~ ^[Yy]$ ]]; then
		
		if test -f ~/.ssh/id_rsa; then
			echo "id_rsa already exists"
		else
			echo "Creating id_rsa, Make sure to store your passphrase in 1password"
			ssh-keygen -t rsa -b 4096 -C "$email"
			eval "$(ssh-agent -s)"
			ssh-add -K ~/.ssh/id_rsa
		fi
		if test -f ~/.ssh/config; then
			echo "ssh config already exists"
		else
			cat > ~/.ssh/config <<- "EOF"
			Host *
		  	AddKeysToAgent yes
		  	UseKeychain yes
		  	IdentityFile ~/.ssh/id_rsa
			EOF
			
			echo "ssh key created, added to keychain and ssh config created"
			cat ~/.ssh/id_rsa.pub
			echo "add above pub key to github https://github.com/settings/ssh/new"
		fi
	fi

}





#TODO add process for gpg key generation for github signing
#https://docs.github.com/en/github/authenticating-to-github/managing-commit-signature-verification




 mac-defaults() {
 	#see https://www.defaults-write.com/ for documentation on setting deaults via command line

	read -p "Set Up Mac defaults? " -n 1 -r
	echo    # (optional) move to a new line
	if [[ $REPLY =~ ^[Yy]$ ]]; then
	    echo "Setting some Mac settings..."

	    #Enable Dark mode
	    defaults write /Library/Preferences/.GlobalPreferences AppleInterfaceTheme Dark


	    # Disable animations when opening and closing windows.
		defaults write NSGlobalDomain NSAutomaticWindowAnimationsEnabled -bool false

		# Disable animations when opening a Quick Look window.
		defaults write -g QLPanelAnimationDuration -float 0

		# Accelerated playback when adjusting the window size (Cocoa applications).
		defaults write NSGlobalDomain NSWindowResizeTime -float 0.001

		# Disable animation when opening the Info window in Finder (cmd⌘ + i).
		defaults write com.apple.finder DisableAllAnimations -bool true

		# isable animations when you open an application from the Dock.
		defaults write com.apple.dock launchanim -bool false

		# Make all animations faster that are used by Mission Control.
		defaults write com.apple.dock expose-animation-duration -float 0.1

		# Disable the delay when you hide the Dock
		defaults write com.apple.Dock autohide-delay -float 0

		#"Disabling system-wide resume"
		defaults write NSGlobalDomain NSQuitAlwaysKeepsWindows -bool false


		#"Disabling automatic termination of inactive apps"
		defaults write NSGlobalDomain NSDisableAutomaticTermination -bool true


		#"Allow text selection in Quick Look"
		defaults write com.apple.finder QLEnableTextSelection -bool TRUE



		#"Disabling OS X Gate Keeper"
		#You'll be able to install any app you want from here on, not just Mac App Store apps
		sudo spctl --master-disable
		sudo defaults write /var/db/SystemPolicy-prefs.plist enabled -string no
		defaults write com.apple.LaunchServices LSQuarantine -bool false


		#"Expanding the save panel by default"
		defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
		defaults write NSGlobalDomain PMPrintingExpandedStateForPrint -bool true
		defaults write NSGlobalDomain PMPrintingExpandedStateForPrint2 -bool true

		#"Automatically quit printer app once the print jobs complete"
		defaults write com.apple.print.PrintingPrefs "Quit When Finished" -bool true

		#"Saving to disk (not to iCloud) by default"
		defaults write NSGlobalDomain NSDocumentSaveNewDocumentsToCloud -bool false

		#"Check for software updates daily, not just once per week"
		defaults write com.apple.SoftwareUpdate ScheduleFrequency -int 1

		#"Disable smart quotes and smart dashes as they are annoying when typing code"
		defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false
		defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false

		#"Enabling full keyboard access for all controls (e.g. enable Tab in modal dialogs)"
		defaults write NSGlobalDomain AppleKeyboardUIMode -int 3

		#"Disabling press-and-hold for keys in favor of a key repeat"
		defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false


		#"Setting trackpad & mouse speed to a reasonable number"
		defaults write -g com.apple.trackpad.scaling 2
		defaults write -g com.apple.mouse.scaling 2.5

		#"Enabling subpixel font rendering on non-Apple LCDs"
		defaults write NSGlobalDomain AppleFontSmoothing -int 2


		#"Showing icons for hard drives, servers, and removable media on the desktop"
		defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool true

		#"Showing all filename extensions in Finder by default"
		defaults write NSGlobalDomain AppleShowAllExtensions -bool true

		#"Disabling the warning when changing a file extension"
		defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false

		#"Use column view in all Finder windows by default"
		defaults write com.apple.finder FXPreferredViewStyle Clmv

		#"Avoiding the creation of .DS_Store files on network volumes"
		defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true


		#"Enabling snap-to-grid for icons on the desktop and in other icon views"
		/usr/libexec/PlistBuddy -c "Set :DesktopViewSettings:IconViewSettings:arrangeBy grid" ~/Library/Preferences/com.apple.finder.plist
		/usr/libexec/PlistBuddy -c "Set :FK_StandardViewSettings:IconViewSettings:arrangeBy grid" ~/Library/Preferences/com.apple.finder.plist
		/usr/libexec/PlistBuddy -c "Set :StandardViewSettings:IconViewSettings:arrangeBy grid" ~/Library/Preferences/com.apple.finder.plist

		#"Setting the icon size of Dock items to 36 pixels for optimal size/screen-realestate"
		defaults write com.apple.dock tilesize -int 36

		#"Speeding up Mission Control animations and grouping windows by application"
		defaults write com.apple.dock expose-animation-duration -float 0.1
		defaults write com.apple.dock "expose-group-by-app" -bool true

		#"Setting Dock to auto-hide and removing the auto-hiding delay"
		defaults write com.apple.dock autohide -bool true
		defaults write com.apple.dock autohide-delay -float 0
		defaults write com.apple.dock autohide-time-modifier -float 0

		#"Setting email addresses to copy as 'foo@example.com' instead of 'Foo Bar <foo@example.com>' in Mail.app"
		defaults write com.apple.mail AddressesIncludeNameOnPasteboard -bool false



		#"Enabling UTF-8 ONLY in Terminal.app and setting the Pro theme by default"
		defaults write com.apple.terminal StringEncodings -array 4
		defaults write com.apple.Terminal "Default Window Settings" -string "Pro"
		defaults write com.apple.Terminal "Startup Window Settings" -string "Pro"


		#"Preventing Time Machine from prompting to use new hard drives as backup volume"
		defaults write com.apple.TimeMachine DoNotOfferNewDisksForBackup -bool true

		#"Disable the sudden motion sensor as its not useful for SSDs"
		sudo pmset -a sms 0

		#"Speeding up wake from sleep to 24 hours from an hour"
		# http://www.cultofmac.com/221392/quick-hack-speeds-up-retina-macbooks-wake-from-sleep-os-x-tips/
		sudo pmset -a standbydelay 86400



		#"Disable annoying backswipe in Chrome"
		defaults write com.google.Chrome AppleEnableSwipeNavigateWithScrolls -bool false

		#"Setting screenshots location to ~/Desktop"
		defaults write com.apple.screencapture location -string "$HOME/Desktop"


		#"Adding a context menu item for showing the Web Inspector in web views"
		defaults write NSGlobalDomain WebKitDeveloperExtras -bool true


		#"Use `~/Downloads/Incomplete` to store incomplete downloads"
		defaults write org.m0k.transmission UseIncompleteDownloadFolder -bool true
		defaults write org.m0k.transmission IncompleteDownloadFolder -string "${HOME}/Downloads/Incomplete"

		#"Don't prompt for confirmation before downloading"
		defaults write org.m0k.transmission DownloadAsk -bool false

		#"Trash original torrent files"
		defaults write org.m0k.transmission DeleteOriginalTorrent -bool true

		#"Hide the donate message"
		defaults write org.m0k.transmission WarningDonate -bool false

		#"Hide the legal disclaimer"
		defaults write org.m0k.transmission WarningLegal -bool false

		#"Disable 'natural' (Lion-style) scrolling"
		defaults write NSGlobalDomain com.apple.swipescrolldirection -bool false

		# Don’t automatically rearrange Spaces based on most recent use
		defaults write com.apple.dock mru-spaces -bool false
		killall Finder
		echo "Done!"
	fi

}






main
