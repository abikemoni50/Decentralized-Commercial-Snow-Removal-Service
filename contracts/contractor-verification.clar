;; Contractor Verification Contract
;; Validates qualified service providers

(define-data-var contract-owner principal tx-sender)

;; Contractor struct
(define-map contractors
  { contractor-id: principal }
  {
    name: (string-utf8 256),
    contact-info: (string-utf8 256),
    equipment: (string-utf8 256),
    verified: bool,
    rating: uint,
    review-count: uint,
    active: bool
  }
)

;; Add a new contractor
(define-public (register-contractor (name (string-utf8 256)) (contact-info (string-utf8 256)) (equipment (string-utf8 256)))
  (begin
    (map-insert contractors
      { contractor-id: tx-sender }
      {
        name: name,
        contact-info: contact-info,
        equipment: equipment,
        verified: false,
        rating: u0,
        review-count: u0,
        active: true
      }
    )
    (ok true)
  )
)

;; Verify a contractor (only contract owner can verify)
(define-public (verify-contractor (contractor-id principal))
  (let
    (
      (contractor (unwrap! (map-get? contractors { contractor-id: contractor-id }) (err u106)))
    )
    (asserts! (is-eq tx-sender (var-get contract-owner)) (err u100))
    (map-set contractors
      { contractor-id: contractor-id }
      {
        name: (get name contractor),
        contact-info: (get contact-info contractor),
        equipment: (get equipment contractor),
        verified: true,
        rating: (get rating contractor),
        review-count: (get review-count contractor),
        active: (get active contractor)
      }
    )
    (ok true)
  )
)

;; Update contractor details
(define-public (update-contractor (name (string-utf8 256)) (contact-info (string-utf8 256)) (equipment (string-utf8 256)))
  (let
    (
      (contractor (unwrap! (map-get? contractors { contractor-id: tx-sender }) (err u106)))
    )
    (map-set contractors
      { contractor-id: tx-sender }
      {
        name: name,
        contact-info: contact-info,
        equipment: equipment,
        verified: (get verified contractor),
        rating: (get rating contractor),
        review-count: (get review-count contractor),
        active: (get active contractor)
      }
    )
    (ok true)
  )
)

;; Add a review and update rating
(define-public (add-review (contractor-id principal) (rating-value uint))
  (let
    (
      (contractor (unwrap! (map-get? contractors { contractor-id: contractor-id }) (err u106)))
      (current-rating (get rating contractor))
      (current-count (get review-count contractor))
      (new-count (+ current-count u1))
      ;; Calculate new average rating
      (new-rating (/ (+ (* current-rating current-count) rating-value) new-count))
    )
    (asserts! (<= rating-value u5) (err u107)) ;; Rating must be between 0-5
    (map-set contractors
      { contractor-id: contractor-id }
      {
        name: (get name contractor),
        contact-info: (get contact-info contractor),
        equipment: (get equipment contractor),
        verified: (get verified contractor),
        rating: new-rating,
        review-count: new-count,
        active: (get active contractor)
      }
    )
    (ok true)
  )
)

;; Set contractor active status
(define-public (set-contractor-status (active bool))
  (let
    (
      (contractor (unwrap! (map-get? contractors { contractor-id: tx-sender }) (err u106)))
    )
    (map-set contractors
      { contractor-id: tx-sender }
      {
        name: (get name contractor),
        contact-info: (get contact-info contractor),
        equipment: (get equipment contractor),
        verified: (get verified contractor),
        rating: (get rating contractor),
        review-count: (get review-count contractor),
        active: active
      }
    )
    (ok true)
  )
)

;; Get contractor details
(define-read-only (get-contractor (contractor-id principal))
  (map-get? contractors { contractor-id: contractor-id })
)

;; Check if contractor is verified
(define-read-only (is-verified (contractor-id principal))
  (default-to false (get verified (map-get? contractors { contractor-id: contractor-id })))
)

;; Initialize contract
(define-public (initialize (owner principal))
  (begin
    (asserts! (is-eq tx-sender (var-get contract-owner)) (err u100))
    (var-set contract-owner owner)
    (ok true)
  )
)
