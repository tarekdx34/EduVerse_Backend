🌐 Community Module

What It Does

A course-scoped social forum where users can create posts, comment, and react. It has 4 entities:

┌─────────────────────┬────────────────────────────┬────────────────────────────────────────────────────────────┐
│ Entity │ Table │ Purpose │
├─────────────────────┼────────────────────────────┼────────────────────────────────────────────────────────────┤
│ CommunityPost │ community_posts │ Main posts in a course forum │
├─────────────────────┼────────────────────────────┼────────────────────────────────────────────────────────────┤
│ CommunityComment │ community_post_comments │ Comments on posts (supports nesting via parentCommentId) │
├─────────────────────┼────────────────────────────┼────────────────────────────────────────────────────────────┤
│ CommunityReaction │ community_post_reactions │ Like/Helpful/Insightful/Thanks reactions on posts │
├─────────────────────┼────────────────────────────┼────────────────────────────────────────────────────────────┤
│ ForumCategory │ forum_categories │ Category tags per course (General, Resources, etc.) │
└─────────────────────┴────────────────────────────┴────────────────────────────────────────────────────────────┘

Post Fields

- title, content, courseId, userId
- postType: enum → DISCUSSION | QUESTION | ANNOUNCEMENT | RESOURCE
- isPinned, isLocked, viewCount, upvoteCount, replyCount

All Endpoints

┌──────────┬──────────────────────────────────────┬─────────────────────┬───────────────────────────────────────────────────────────────────┐  
 │ Method │ Path │ Who │ Notes │  
 ├──────────┼──────────────────────────────────────┼─────────────────────┼───────────────────────────────────────────────────────────────────┤  
 │ GET │ /api/community/posts │ All authenticated │ Filter by courseId, postType, sort │  
 │ │ │ │ (recent/popular/most_comments), paginated │  
 ├──────────┼──────────────────────────────────────┼─────────────────────┼───────────────────────────────────────────────────────────────────┤  
 │ POST │ /api/community/posts │ All authenticated │ Create post with courseId, title, content, postType │  
 ├──────────┼──────────────────────────────────────┼─────────────────────┼───────────────────────────────────────────────────────────────────┤  
 │ GET │ /api/community/posts/:id │ All authenticated │ Returns { post, comments: { data, meta }, reactions } │  
 ├──────────┼──────────────────────────────────────┼─────────────────────┼───────────────────────────────────────────────────────────────────┤  
 │ PUT │ /api/community/posts/:id │ Author or │ Edit title/content/type │  
 │ │ │ Instructor/Admin │ │  
 ├──────────┼──────────────────────────────────────┼─────────────────────┼───────────────────────────────────────────────────────────────────┤  
 │ DELETE │ /api/community/posts/:id │ Author or │ Cascade deletes comments/reactions │  
 │ │ │ Instructor/Admin │ │  
 ├──────────┼──────────────────────────────────────┼─────────────────────┼───────────────────────────────────────────────────────────────────┤  
 │ PATCH │ /api/community/posts/:id/pin │ Instructor/TA/Admin │ Toggle pin │  
 │ │ │ only │ │  
 ├──────────┼──────────────────────────────────────┼─────────────────────┼───────────────────────────────────────────────────────────────────┤  
 │ PATCH │ /api/community/posts/:id/lock │ Instructor/TA/Admin │ Toggle lock │  
 │ │ │ only │ │  
 ├──────────┼──────────────────────────────────────┼─────────────────────┼───────────────────────────────────────────────────────────────────┤  
 │ POST │ /api/community/posts/:id/comment │ All authenticated │ Add comment, optional parentCommentId for nested replies │  
 ├──────────┼──────────────────────────────────────┼─────────────────────┼───────────────────────────────────────────────────────────────────┤  
 │ PUT │ /api/community/comments/:id │ Author only │ Edit comment text │  
 ├──────────┼──────────────────────────────────────┼─────────────────────┼───────────────────────────────────────────────────────────────────┤  
 │ DELETE │ /api/community/comments/:id │ Author or │ Delete comment │  
 │ │ │ Instructor/Admin │ │  
 ├──────────┼──────────────────────────────────────┼─────────────────────┼───────────────────────────────────────────────────────────────────┤  
 │ POST │ /api/community/posts/:id/reactions │ All authenticated │ Toggle reaction (like/helpful/insightful/thanks) — adds if not │  
 │ │ │ │ exists, removes if exists │  
 ├──────────┼──────────────────────────────────────┼─────────────────────┼───────────────────────────────────────────────────────────────────┤  
 │ GET │ /api/community/categories │ All authenticated │ List categories, filter by courseId │  
 ├──────────┼──────────────────────────────────────┼─────────────────────┼───────────────────────────────────────────────────────────────────┤  
 │ POST │ /api/community/categories │ Admin/Instructor │ Create category │  
 │ │ │ only │ │  
 ├──────────┼──────────────────────────────────────┼─────────────────────┼───────────────────────────────────────────────────────────────────┤  
 │ PUT │ /api/community/categories/:id │ Admin/Instructor │ Update category │  
 │ │ │ only │ │  
 ├──────────┼──────────────────────────────────────┼─────────────────────┼───────────────────────────────────────────────────────────────────┤  
 │ DELETE │ /api/community/categories/:id │ Admin/Instructor │ Delete category │  
 │ │ │ only │ │  
 └──────────┴──────────────────────────────────────┴─────────────────────┴───────────────────────────────────────────────────────────────────┘

---

💬 Discussions Module

What It Does

A Q&A system — students create threads (questions/problems), staff/peers reply. Replies can be marked as the accepted answer or endorsed by  
 instructors.

┌────────────────────┬──────────────────────────┬────────────────────────────────┐
│ Entity │ Table │ Purpose │
├────────────────────┼──────────────────────────┼────────────────────────────────┤
│ CourseChatThread │ (threads table) │ The question/discussion thread │
├────────────────────┼──────────────────────────┼────────────────────────────────┤
│ ChatMessage │ (messages/replies table) │ Individual replies in a thread │
└────────────────────┴──────────────────────────┴────────────────────────────────┘

Thread Fields

- courseId, createdBy, title, description
- isPinned, isLocked, viewCount, replyCount

Reply Fields

- threadId, userId, messageText, parentMessageId (nested replies)
- isAnswer (accepted answer toggle), isEndorsed + endorsedBy (instructor endorsement)
- upvoteCount

All Endpoints

┌──────────┬────────────────────────────────────────────┬───────────────────────┬───────────────────────────────────────────────────────────┐  
 │ Method │ Path │ Who │ Notes │  
 ├──────────┼────────────────────────────────────────────┼───────────────────────┼───────────────────────────────────────────────────────────┤  
 │ GET │ /api/discussions │ All authenticated │ Filter by courseId, paginated. Pinned threads appear │  
 │ │ │ │ first │  
 ├──────────┼────────────────────────────────────────────┼───────────────────────┼───────────────────────────────────────────────────────────┤  
 │ POST │ /api/discussions │ All authenticated │ Create thread with courseId, title, description │  
 ├──────────┼────────────────────────────────────────────┼───────────────────────┼───────────────────────────────────────────────────────────┤  
 │ GET │ /api/discussions/:id │ All authenticated │ Returns { thread, replies: { data, meta } } — answers │  
 │ │ │ │ shown first │  
 ├──────────┼────────────────────────────────────────────┼───────────────────────┼───────────────────────────────────────────────────────────┤  
 │ PUT │ /api/discussions/:id │ Author or │ Edit title/description │  
 │ │ │ Instructor/Admin │ │  
 ├──────────┼────────────────────────────────────────────┼───────────────────────┼───────────────────────────────────────────────────────────┤  
 │ DELETE │ /api/discussions/:id │ Instructor/TA/Admin │ Cascade deletes replies │  
 │ │ │ only │ │  
 ├──────────┼────────────────────────────────────────────┼───────────────────────┼───────────────────────────────────────────────────────────┤  
 │ POST │ /api/discussions/:id/reply │ All authenticated │ Add reply — blocked if thread is locked │  
 ├──────────┼────────────────────────────────────────────┼───────────────────────┼───────────────────────────────────────────────────────────┤  
 │ PATCH │ /api/discussions/:id/pin │ Instructor/TA/Admin │ Toggle pin │  
 │ │ │ only │ │  
 ├──────────┼────────────────────────────────────────────┼───────────────────────┼───────────────────────────────────────────────────────────┤  
 │ PATCH │ /api/discussions/:id/lock │ Instructor/TA/Admin │ Toggle lock (prevents new replies) │  
 │ │ │ only │ │  
 ├──────────┼────────────────────────────────────────────┼───────────────────────┼───────────────────────────────────────────────────────────┤  
 │ PATCH │ /api/discussions/replies/:id/mark-answer │ Instructor/TA/Admin │ Toggle accepted answer │  
 │ │ │ only │ │  
 ├──────────┼────────────────────────────────────────────┼───────────────────────┼───────────────────────────────────────────────────────────┤  
 │ PATCH │ /api/discussions/replies/:id/endorse │ Instructor/TA/Admin │ Toggle instructor endorsement │  
 │ │ │ only │ │  
 └──────────┴────────────────────────────────────────────┴───────────────────────┴───────────────────────────────────────────────────────────┘

---

⚠️ Gap Analysis — vs Your Vision

Your Vision vs Current Implementation

┌───────────────────────────┬───────────────────────────────────────────────┬───────────────────────────────────────────────────────────────┐  
 │ Feature │ Your Vision │ Current State │  
 ├───────────────────────────┼───────────────────────────────────────────────┼───────────────────────────────────────────────────────────────┤  
 │ Community = │ Only enrolled students + course │ ❌ Any authenticated user can read/post in any course │  
 │ course-specific │ TAs/instructors │ │  
 ├───────────────────────────┼───────────────────────────────────────────────┼───────────────────────────────────────────────────────────────┤  
 │ Discussion = Q&A │ Students ask, TA/Instructor answer/endorse │ ✅ Structure exists (mark-answer, endorse) │  
 │ (edX-style) │ │ │  
 ├───────────────────────────┼───────────────────────────────────────────────┼───────────────────────────────────────────────────────────────┤  
 │ Enrollment check │ Only enrolled users can access their course │ ❌ NO enrollment check anywhere in discussions or community │  
 │ │ content │ │  
 ├───────────────────────────┼───────────────────────────────────────────────┼───────────────────────────────────────────────────────────────┤  
 │ Course staff check │ Instructors/TAs of THAT course can moderate │ ❌ Any instructor/admin can moderate any course │  
 ├───────────────────────────┼───────────────────────────────────────────────┼───────────────────────────────────────────────────────────────┤  
 │ Community post types │ Separation of discussions, questions, │ ✅ postType enum: DISCUSSION/QUESTION/ANNOUNCEMENT/RESOURCE │  
 │ │ announcements │ │  
 ├───────────────────────────┼───────────────────────────────────────────────┼───────────────────────────────────────────────────────────────┤  
 │ Nested replies │ Deep comment threads │ ✅ parentCommentId in community, parentMessageId in │  
 │ │ │ discussions │  
 ├───────────────────────────┼───────────────────────────────────────────────┼───────────────────────────────────────────────────────────────┤  
 │ Pin/Lock │ Staff can pin important threads │ ✅ Implemented, staff-only │  
 ├───────────────────────────┼───────────────────────────────────────────────┼───────────────────────────────────────────────────────────────┤  
 │ Reactions │ Helpful/Like/etc. │ ✅ Only on community posts, not on discussion replies │  
 └───────────────────────────┴───────────────────────────────────────────────┴───────────────────────────────────────────────────────────────┘

Critical Missing Pieces

1. No Enrollment Guard (biggest gap)
   Neither module checks if a user is enrolled in or assigned to the course. The announcements module has this pattern already — it queries  
   CourseEnrollment, CourseInstructor, CourseTA tables to filter accessible courses. Neither community nor discussions use this.

2. postType not linked to discussion module
   Community has QUESTION as a post type, AND there's a separate Discussions module. This creates confusion — should questions go in Community  
   or Discussions? Currently they're separate silos with no cross-linking.

3. No upvote action endpoint in discussions
   ChatMessage has upvoteCount but there's no POST /api/discussions/replies/:id/upvote endpoint.

4. No reaction support on discussion replies
   Community has reactions (like/helpful/insightful/thanks) on posts only — nothing on discussion replies.

5. Discussion entity naming is misleading
   The discussion entities are named CourseChatThread and ChatMessage — sounds like a chat system, not a Q&A forum. The naming doesn't match the  
   intended Q&A behavior.

---

Summary

┌─────────────────┬──────────────────────────────────────────┬───────────────────┬──────────────────────────────────────────────────────────┐  
 │ Module │ Implementation Completeness │ Access Control │ Matches Your Vision │  
 ├─────────────────┼──────────────────────────────────────────┼───────────────────┼──────────────────────────────────────────────────────────┤  
 │ Community │ ~85% — all CRUD, reactions, categories │ ❌ No enrollment │ ~60% — missing course isolation │  
 │ │ work │ check │ │  
 ├─────────────────┼──────────────────────────────────────────┼───────────────────┼──────────────────────────────────────────────────────────┤  
 │ Discussions │ ~80% — threads, replies, mark-answer, │ ❌ No enrollment │ ~70% — Q&A structure exists but naming is wrong and no │  
 │ │ endorse work │ check │ upvote action │  
 └─────────────────┴──────────────────────────────────────────┴───────────────────┴──────────────────────────────────────────────────────────┘

The biggest single fix needed is adding enrollment/course-staff verification guards to both modules — the pattern already exists in the  
 announcements module and could be ported.
