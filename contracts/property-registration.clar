;; Property Registration Contract
;; Records details of serviced locations

(define-data-var contract-owner principal tx-sender)

;; Property struct
(define-map properties
  { property-id: uint }
  {
    owner: principal,
    address: (string-utf8 256),
    size: uint,
    service-level: (string-utf8 64),
    active: bool
  }
)

;; Property counter
(define-data-var property-counter uint u0)

;; Register a new property
(define-public (register-property (address (string-utf8 256)) (size uint) (service-level (string-utf8 64)))
  (let
    (
      (property-id (var-get property-counter))
    )
    (asserts! (is-eq tx-sender (var-get contract-owner)) (err u100))
    (map-insert properties
      { property-id: property-id }
      {
        owner: tx-sender,
        address: address,
        size: size,
        service-level: service-level,
        active: true
      }
    )
    (var-set property-counter (+ property-id u1))
    (ok property-id)
  )
)

;; Update property details
(define-public (update-property (property-id uint) (address (string-utf8 256)) (size uint) (service-level (string-utf8 64)))
  (let
    (
      (property (unwrap! (map-get? properties { property-id: property-id }) (err u101)))
    )
    (asserts! (is-eq (get owner property) tx-sender) (err u102))
    (map-set properties
      { property-id: property-id }
      {
        owner: tx-sender,
        address: address,
        size: size,
        service-level: service-level,
        active: (get active property)
      }
    )
    (ok true)
  )
)

;; Activate/Deactivate property
(define-public (set-property-status (property-id uint) (active bool))
  (let
    (
      (property (unwrap! (map-get? properties { property-id: property-id }) (err u101)))
    )
    (asserts! (is-eq (get owner property) tx-sender) (err u102))
    (map-set properties
      { property-id: property-id }
      {
        owner: (get owner property),
        address: (get address property),
        size: (get size property),
        service-level: (get service-level property),
        active: active
      }
    )
    (ok true)
  )
)

;; Read property details
(define-read-only (get-property (property-id uint))
  (map-get? properties { property-id: property-id })
)

;; Initialize contract
(define-public (initialize (owner principal))
  (begin
    (asserts! (is-eq tx-sender (var-get contract-owner)) (err u100))
    (var-set contract-owner owner)
    (ok true)
  )
)
