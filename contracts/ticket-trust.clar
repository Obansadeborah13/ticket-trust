(define-map events
  {event-id: uint}
  {organizer: principal, name: (string-ascii 50), ticket-price: uint, 
   ticket-cap: uint, tickets-sold: uint, is-cancelled: bool})

(define-map tickets
  {ticket-id: uint}
  {event-id: uint, owner: principal, resale-price: uint})

(define-data-var event-counter uint u1)
(define-data-var ticket-counter uint u1)
(define-constant max-resale-rate 120) ;; 120% max resale

;; Create a new event
(define-public (create-event (name (string-ascii 50)) (ticket-price uint) (ticket-cap uint))
  (let ((event-id (var-get event-counter)))
    (begin
      (map-set events 
        {event-id: event-id}
        {organizer: tx-sender, 
         name: name, 
         ticket-price: ticket-price, 
         ticket-cap: ticket-cap, 
         tickets-sold: u0, 
         is-cancelled: false})
      (var-set event-counter (+ event-id u1))
      (ok event-id))))

;; Buy ticket (mint NFT-like ticket)
(define-public (mint-ticket (event-id uint))
  (let ((event-data (map-get? events {event-id: event-id}))
        (ticket-id (var-get ticket-counter)))
    (match event-data
      event (if (is-eq (get is-cancelled event) false)
              (if (< (get tickets-sold event) (get ticket-cap event))
                (begin
                  (try! (stx-transfer? (get ticket-price event) tx-sender (get organizer event)))
                  ;; Issue ticket
                  (map-set tickets 
                    {ticket-id: ticket-id}
                    {event-id: event-id, owner: tx-sender, resale-price: (get ticket-price event)})
                  ;; Update event sales
                  (map-set events 
                    {event-id: event-id}
                    {organizer: (get organizer event), name: (get name event), 
                     ticket-price: (get ticket-price event), ticket-cap: (get ticket-cap event),
                     tickets-sold: (+ (get tickets-sold event) u1), is-cancelled: false})
                  (var-set ticket-counter (+ ticket-id u1))
                  (ok ticket-id))
                (err u2))  ;; Tickets sold out error code
              (err u1))   ;; Event cancelled error code
      (err u0))))        ;; Event not found error code

;; Resell ticket with price cap
(define-public (resell-ticket (ticket-id uint) (buyer principal) (price uint))
  (let ((ticket (map-get? tickets {ticket-id: ticket-id})))
    (match ticket 
      t
      (let ((event-data (map-get? events {event-id: (get event-id t)})))
        (match event-data 
          event
          (if (<= (* price u100) (* (get ticket-price event) (to-uint max-resale-rate)))
            (if (is-eq tx-sender (get owner t))
              (begin
                (try! (stx-transfer? price buyer tx-sender))
                (map-set tickets 
                  {ticket-id: ticket-id}
                  {event-id: (get event-id t), owner: buyer, resale-price: price})
                (ok ticket-id))
              (err u3))  ;; Unauthorized error code
            (err u4))    ;; Price too high error code
          (err u0)))     ;; Event not found error code
      (err u5))))        ;; Ticket not found error code

;; Cancel event and refund
(define-public (cancel-event (event-id uint))
  (let ((event-data (map-get? events {event-id: event-id})))
    (match event-data 
      event
      (if (is-eq tx-sender (get organizer event))
        (begin
          (map-set events 
            {event-id: event-id}
            {organizer: (get organizer event), name: (get name event), 
             ticket-price: (get ticket-price event), ticket-cap: (get ticket-cap event),
             tickets-sold: (get tickets-sold event), is-cancelled: true})
          (ok "Event cancelled, refunds to be handled manually"))
        (err "Unauthorized"))
      (err "Event not found"))))

;; READ-ONLY FUNCTIONS
(define-read-only (get-event (event-id uint))
  (map-get? events {event-id: event-id}))

(define-read-only (get-ticket-owner (ticket-id uint))
  (let ((ticket (map-get? tickets {ticket-id: ticket-id})))
    (match ticket t
      (ok (get owner t))
      (err "Ticket not found"))))
