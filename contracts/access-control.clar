;; Access Control Contract
;; Controls research data access permissions

;; Constants
(define-constant err-unauthorized (err u400))
(define-constant err-not-found (err u401))
(define-constant err-access-denied (err u402))
(define-constant err-invalid-permission (err u403))

;; Data Variables
(define-data-var next-permission-id uint u1)

;; Data Maps
(define-map access-permissions
  { permission-id: uint }
  {
    data-id: uint,
    grantee: principal,
    grantor: principal,
    permission-type: (string-ascii 10), ;; "read", "write", "admin"
    granted-at: uint,
    expires-at: (optional uint),
    active: bool
  }
)

(define-map user-data-access
  { user: principal, data-id: uint }
  { permission-id: uint }
)

(define-map data-access-list
  { data-id: uint, user: principal }
  { has-access: bool }
)

;; Public Functions

;; Grant access to data
(define-public (grant-access
  (data-id uint)
  (grantee principal)
  (permission-type (string-ascii 10))
  (expires-at (optional uint))
)
  (let ((permission-id (var-get next-permission-id)))
    ;; Validate permission type
    (asserts! (or (is-eq permission-type "read")
                  (is-eq permission-type "write")
                  (is-eq permission-type "admin")) err-invalid-permission)

    (map-set access-permissions
      { permission-id: permission-id }
      {
        data-id: data-id,
        grantee: grantee,
        grantor: tx-sender,
        permission-type: permission-type,
        granted-at: block-height,
        expires-at: expires-at,
        active: true
      }
    )

    (map-set user-data-access
      { user: grantee, data-id: data-id }
      { permission-id: permission-id }
    )

    (map-set data-access-list
      { data-id: data-id, user: grantee }
      { has-access: true }
    )

    (var-set next-permission-id (+ permission-id u1))
    (ok permission-id)
  )
)

;; Revoke access
(define-public (revoke-access (permission-id uint))
  (match (map-get? access-permissions { permission-id: permission-id })
    permission-info
    (begin
      (asserts! (is-eq tx-sender (get grantor permission-info)) err-unauthorized)

      (map-set access-permissions
        { permission-id: permission-id }
        (merge permission-info { active: false })
      )

      (map-set data-access-list
        { data-id: (get data-id permission-info), user: (get grantee permission-info) }
        { has-access: false }
      )

      (ok true)
    )
    err-not-found
  )
)

;; Check access (public function for external verification)
(define-public (verify-access (user principal) (data-id uint) (required-permission (string-ascii 10)))
  (ok (check-user-access user data-id required-permission))
)

;; Read-only Functions

;; Check if user has access to data
(define-read-only (check-user-access (user principal) (data-id uint) (required-permission (string-ascii 10)))
  (match (map-get? user-data-access { user: user, data-id: data-id })
    access-info
    (match (map-get? access-permissions { permission-id: (get permission-id access-info) })
      permission-info
      (and
        (get active permission-info)
        (or (is-eq (get permission-type permission-info) required-permission)
            (is-eq (get permission-type permission-info) "admin"))
        (match (get expires-at permission-info)
          expiry (< block-height expiry)
          true)
      )
      false
    )
    false
  )
)

;; Get permission details
(define-read-only (get-permission (permission-id uint))
  (map-get? access-permissions { permission-id: permission-id })
)

;; Check if access exists
(define-read-only (has-access (user principal) (data-id uint))
  (default-to false (get has-access (map-get? data-access-list { data-id: data-id, user: user })))
)
