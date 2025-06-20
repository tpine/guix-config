(in-package :stumpwm)

;;; Visual
(defvar *themes* (make-hash-table))
(defun add-theme (name theme)
  (setf (gethash name *themes*) theme))

;;; Colors based off spacemacs-dark-theme for emacs
(defclass theme ()
    ((fg
      :initarg :fg
      :type string)
     (bg
      :initarg :bg
      :type string)

     (border
      :initarg :border
      :type string)

     (focus
      :initarg :focus
      :type string)
     (unfocus
      :initarg :unfocus
      :type string)

     (mode-line-fg
      :initarg :mode-line-fg
      :type string)
     (mode-line-bg
      :initarg :mode-line-bg
      :type string)
     (mode-line-border
      :initarg :mode-line-border
      :type string)

     (color-map-first
      :initarg :color-map-first
      :type string)
     (color-map-last
      :initarg :color-map-last
      :type string)))

(defun apply-theme (theme)
  (set-fg-color (slot-value theme 'fg))
  (set-bg-color (slot-value theme 'bg))
  (set-border-color (slot-value theme 'border))
  (set-focus-color (slot-value theme 'focus))
  (set-unfocus-color (slot-value theme 'unfocus))

  (setf *mode-line-foreground-color* (slot-value theme 'mode-line-fg)
	*mode-line-background-color* (slot-value theme 'mode-line-bg)
	*mode-line-border-color* (slot-value theme 'mode-line-border))
  
  (setf (car *colors*) (slot-value theme 'color-map-first)
	(car (last *colors*)) (slot-value theme 'color-map-last))
  (update-color-map (current-screen)))

(let ((grey "#292b2e")
      (purple "#5d4d7a"))
  (add-theme 'spacemacs
	     (make-instance 'theme
	      :fg purple
	      :bg grey
	      :border purple
	      :focus purple
	      :unfocus grey
	      :mode-line-fg purple
	      :mode-line-bg grey
	      :mode-line-border purple
	      :color-map-first grey
	      :color-map-last purple)))

(let ((fg "#ebdbb2")
      (bg "#282828")
      (border "#665c54"))
  (add-theme 'gruvbox
	     (make-instance 'theme
	      :fg fg
	      :bg bg
	      :border border
	      :focus fg
	      :unfocus bg
	      :mode-line-fg fg
	      :mode-line-bg bg
	      :mode-line-border border
	      :color-map-first bg
	      :color-map-last fg)))

(let ((fg "#F8F8F2")
      (bg "#282A36")
      (border "#8BE9FD")
      (purple "#BD93F9"))
  (add-theme 'dracula
	     (make-instance 'theme
	      :fg fg
	      :bg bg
	      :border purple
	      :focus border
	      :unfocus purple
	      :mode-line-fg purple
	      :mode-line-bg bg
	      :mode-line-border purple
	      :color-map-first bg
	      :color-map-last fg)))


(apply-theme (gethash 'dracula *themes*))

;;; Load battery module
;; (load-module "notify")

;; Set notification text color to yellow to make it obvious
;; (in-package :notify)
;; (defun show-notification (app icon summary body)
;;   "Show the notification using standard STUMPWM::MESSAGE function"
;;   (declare (ignore app icon))
;;   (stumpwm:message "^B^[^3*~A ~A^]" summary body))
;; ;;; Start notification server
;; (notify-server-toggle)

;; (load-module :ttf-fonts)

(in-package :stumpwm)

(run-shell-command "feh --bg-fill --no-xinerama ~/.background.jpg")
;; (load-module :battery-portable)

;; (ql:quickload :clx-truetype)
;; (load-module "ttf-fonts")
;; (xft:cache-fonts)
;; (set-font (make-instance 'xft:font :family "DejaVu Sans Mono" :subfamily "Bold" :slant "r" :size 10))

;; (defun get-utc-time ()
;;   (subseq (run-shell-command "date -u +%H:%M" t) 0 5))


;; Show time, cpu usage and network traffic in the modelinecomment 
(setf *screen-mode-line-format*
      (list "%W"))

(setf *window-format* "%n %10c: %15t")

;;; When windows are desroyed window numbers are not synced
;;; 2kays <https://github.com/2kays> posted a solution on
;;; the TipsAndTricks section of the wiki
;;; This will repack window numbers every time a window is killed
(stumpwm:add-hook stumpwm:*destroy-window-hook*
                  #'(lambda (win) (stumpwm:repack-window-numbers)))

;; Turn on the modeline
(mapcar (lambda (head)
	  (toggle-mode-line (current-screen) head))
	(screen-heads (current-screen)))
