(define-module (system))

(use-modules (gnu)
	     (gnu services)
	     (gnu packages shells)
	     (gnu packages wm)
	     (gnu packages lisp-xyz)

	     (guix packages)
	     (guix utils)
     
	     (nongnu packages linux)
	     (nongnu system linux-initrd)

	     (srfi srfi-1))

(use-service-modules cups desktop networking ssh xorg docker)

(define-public stumpwm-with-local-time
  (package
    (inherit stumpwm)
    (name "stumpwm-with-local-time")
    (inputs
     (list sbcl-local-time stumpwm))
    (arguments
     (substitute-keyword-arguments (package-arguments stumpwm)
       ((#:phases phases)
        `(modify-phases ,phases
           (replace 'build-program
             (lambda* (#:key inputs outputs #:allow-other-keys)
               (let* ((out (assoc-ref outputs "out"))
                      (program (string-append out "/bin/stumpwm")))
                 (setenv "HOME" "/tmp")
                 (build-program program outputs
                                #:entry-program '((stumpwm:stumpwm) 0)
                                #:dependencies '("stumpwm" "local-time")
                                #:dependency-prefixes
                                (map (lambda (input) (assoc-ref inputs input))
                                     '("stumpwm" "sbcl-local-time"))))))
           (delete 'copy-source)
           (delete 'build)
           (delete 'check)
           (delete 'remove-temporary-cache)
           (delete 'cleanup)))))))

(operating-system
  (kernel linux)
  (initrd microcode-initrd)
  (firmware (list linux-firmware))
  (locale "en_AU.utf8")
  (timezone "Australia/Sydney")
  (keyboard-layout (keyboard-layout "au"))
  (host-name "reason")

  (users (cons* (user-account
                 (name "thomas")
                 (comment "Thomas Atkinson")
                 (group "users")
                 (home-directory "/home/thomas")
		 (shell (file-append zsh "/bin/zsh"))
                 (supplementary-groups '("wheel" "netdev" "audio" "video" "docker" "lp")))
                %base-user-accounts))

  (packages (append
	     (specifications->packages
	      '("blueman"
		"bluez"
		"bluez-alsa"
		"glibc-locales"
		"alsa-plugins"
		"xdg-utils"
		"firefox"
		"zsh"
		"font-google-noto"
		"font-liberation"
		"hicolor-icon-theme"
		;; For setting the screenshot time
		"sbcl-local-time"))
	     (list stumpwm-with-local-time)
             %base-packages))

  (services
   (append (list
	    (service bluetooth-service-type
		     (bluetooth-configuration (auto-enable? #t)
					      (multi-profile 'multiple)))	    
	    (service iwd-service-type)
	    (service connman-service-type
		     (connman-configuration
		      (disable-vpn? #t)
		      (shepherd-requirement '(iwd))))
	    (service containerd-service-type)
	    (service docker-service-type)
	    (service cups-service-type)
	    (service gnome-keyring-service-type)
	    (service gnome-desktop-service-type)
	    (set-xorg-configuration
	     (xorg-configuration (keyboard-layout keyboard-layout))))
	   (modify-services %desktop-services
	     (delete wpa-supplicant-service-type)
	     (delete network-manager-service-type)
	     (guix-service-type config => (guix-configuration
					   (inherit config)
					   (substitute-urls
					    (append (list "https://substitutes.nonguix.org")
						    %default-substitute-urls))
					   (authorized-keys
					    (append (list (local-file "./files/nonguix/signing-key.pub"))
						    %default-authorized-guix-keys)))))))
  
  (bootloader (bootloader-configuration
               (bootloader grub-efi-bootloader)
               (targets (list "/boot/efi"))
               (keyboard-layout keyboard-layout)))

  (file-systems (cons* (file-system
                         (mount-point "/home/thomas")
                         (device (uuid
                                  "930472ef-8c72-4154-92fb-8d045196d45e"
                                  'btrfs))
                         (type "btrfs"))
                       (file-system
                         (mount-point "/steam")
                         (device (uuid
                                  "782358bc-ce0d-4ef3-b6d1-6655b619a883"
                                  'ext4))
                         (type "ext4"))
                       (file-system
                         (mount-point "/boot/efi")
                         (device (uuid "E80B-DBBE"
                                       'fat32))
                         (type "vfat"))
                       (file-system
                         (mount-point "/")
                         (device (uuid
                                  "a49c3c67-4927-41d6-b48f-fa4f5cc2e502"
                                  'ext4))
                         (type "ext4")) %base-file-systems)))
