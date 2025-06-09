;; Research Department Verification Contract
;; Manages verification and registration of research departments

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-found (err u101))
(define-constant err-already-exists (err u102))

;; Data Variables
(define-data-var next-department-id uint u1)

;; Data Maps
(define-map departments
  { department-id: uint }
  {
    name: (string-ascii 50),
    institution: (string-ascii 100),
    contact: principal,
    verified: bool,
    created-at: uint
  }
)

(define-map department-by-principal
  { contact: principal }
  { department-id: uint }
)

;; Public Functions

;; Register a new research department
(define-public (register-department (name (string-ascii 50)) (institution (string-ascii 100)))
  (let ((department-id (var-get next-department-id)))
    (asserts! (is-none (map-get? department-by-principal { contact: tx-sender })) err-already-exists)
    (map-set departments
      { department-id: department-id }
      {
        name: name,
        institution: institution,
        contact: tx-sender,
        verified: false,
        created-at: block-height
      }
    )
    (map-set department-by-principal
      { contact: tx-sender }
      { department-id: department-id }
    )
    (var-set next-department-id (+ department-id u1))
    (ok department-id)
  )
)

;; Verify a department (owner only)
(define-public (verify-department (department-id uint))
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (match (map-get? departments { department-id: department-id })
      department-data
      (begin
        (map-set departments
          { department-id: department-id }
          (merge department-data { verified: true })
        )
        (ok true)
      )
      err-not-found
    )
  )
)

;; Read-only Functions

;; Get department info
(define-read-only (get-department (department-id uint))
  (map-get? departments { department-id: department-id })
)

;; Get department by principal
(define-read-only (get-department-by-principal (contact principal))
  (match (map-get? department-by-principal { contact: contact })
    dept-ref (map-get? departments { department-id: (get department-id dept-ref) })
    none
  )
)

;; Check if department is verified
(define-read-only (is-department-verified (department-id uint))
  (match (map-get? departments { department-id: department-id })
    department-data (get verified department-data)
    false
  )
)
