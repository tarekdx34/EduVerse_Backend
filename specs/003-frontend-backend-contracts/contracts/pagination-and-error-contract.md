# Contract: Pagination and Error Normalization

## 1. Canonical Pagination Envelope

All paginated endpoints targeted by this integration expose:

{
page: number,
limit: number,
total: number,
totalPages: number,
data: array
}

## 2. Query Parameter Convention

- page: 1-based index
- limit: page size
- optional module filters: search, sort, module-specific filters

Frontend rule:

- filter/sort changes reset page to 1.

## 3. Target Modules for Canonicalization

- courses
- enrollments
- grades
- tasks
- notifications
- search
- reports
- messaging conversation/message lists

## 4. Error Normalization Categories

Frontend maps backend/network outcomes into:

- authentication
- authorization
- validation
- conflict
- not-found
- server-error
- transient-network

## 5. Category-to-Action Mapping

- authentication: silent refresh attempt, then sign-in redirect
- authorization: show permission boundary state
- validation: inline field/actionable errors
- conflict: conflict banner with reload/retry guidance
- not-found: safe empty/not-found view
- server-error: retry affordance + support correlation details
- transient-network: auto retry/backoff where safe
