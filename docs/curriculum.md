# Little Bible — Content Development Roadmap

> Full curriculum: see `LITTLE_BIBLE_COMPLETE_CURRICULUM.md`  
> 80 stories · 10 worlds · ages 4–7 · fully progressive, incremental knowledge

---

## Status overview

| Phase | Focus | Stories | Status |
|---|---|---:|---|
| Phase 0 — Ship current app | Finish map UI, release | 15 existing | 🔄 In progress |
| Phase 1 — Complete World 1 | Fill Adam & Eve gap | 4 new | Planned |
| Phase 2 — World 2 | Promise Family (Abraham → Joseph) | 8 new | Planned |
| Phase 3 — World 3 | God Rescues a People (Moses/Exodus) | 8 new | Planned |
| Phase 4 — Complete World 4 | Land Needing a King (fill gaps) | 7 new | Planned |
| Phase 5 — Complete World 5 | Heroes of Faith (fill gaps) | 5 new | Planned |
| Phase 6 — Complete World 6 | Jesus Is Here (fill gaps) | 6 new | Planned |
| Phase 7 — Complete World 7 | Compassionate King (fill gaps) | 3 new | Planned |
| Phase 8 — Complete World 8 | Jesus Saves (fill gaps before cross) | 7 new | Planned |
| Phase 9 — World 9 | Spirit-Filled Family | 8 new | Planned |
| Phase 10 — World 10 | King Makes All Things New | 8 new | Planned |
| **Total new stories** | | **64** | |

---

## Current 15 stories — where they sit in the curriculum

| App order | Story | Curriculum # | World |
|---:|---|---:|---|
| 1 | God Made Everything | 1 | World 1 |
| 2 | God Made Me | 2 | World 1 |
| 3 | Noah's Big Boat | 7 | World 1 |
| 4 | Noah's Rainbow Promise | 8 *(capstone)* | World 1 |
| 5 | David the Shepherd Boy | 32 *(capstone)* | World 4 |
| 6 | Daniel and the Lions | 39 | World 5 |
| 7 | Jonah and the Big Fish | 38 | World 5 |
| 8 | Birth of Jesus | 42 | World 6 |
| 9 | Jesus Loves Children | 48 *(capstone)* | World 6 |
| 10 | The Good Shepherd | 56 *(capstone)* | World 7 |
| 11 | The Lost Sheep | 53 | World 7 |
| 12 | The Lost Son | 54 | World 7 |
| 13 | How to Pray | 55 | World 7 |
| 14 | The Good Neighbour | 52 | World 7 |
| 15 | Jesus Saves | 64 *(capstone)* | World 8 |

**Problem:** the 15 stories are scattered across 7 worlds with large theological gaps between them. Children arriving at David have never heard of sin, covenant, or the Exodus. The curriculum map UI will surface this, but the content gaps need filling before the progression is meaningful.

---

## Phase 0 — Ship current app (DO THIS FIRST)

- [ ] Implement curriculum map UI in `home_screen.dart` (world sections, locked/unlocked tiles)
- [ ] Test end-to-end on emulator (all 15 stories, all 6 game types, coloring, sharing)
- [ ] Build release APK + submit to Play Store
- [ ] **Do not add new stories until Phase 0 is shipped**

---

## Phase 1 — Complete World 1: In the Beginning
*Goal: plug the sin gap so Noah and the Rescuer promise make sense*

| Curriculum # | Story | New Concept | Key Verse |
|---:|---|---|---|
| 3 | The First Family with God | Fellowship | Genesis 2:18 |
| 4 | **The Very Sad Choice** *(Adam & Eve)* | **Sin** | Romans 3:23 |
| 5 | God Promises a Rescuer | First gospel promise | Genesis 3:15 |
| 6 | Two Brothers and Jealous Hearts *(Cain & Abel)* | Indwelling sinful desire | Genesis 4:7 |

World 1 final order: 1 → 2 → **3 → 4 → 5 → 6** → 7 (Noah's Big Boat) → 8 (Noah's Rainbow Promise)

---

## Phase 2 — World 2: Promise Family
*Abraham → Isaac → Jacob → Joseph — faith, covenant, grace, providence*

| Curriculum # | Story | New Concept | Key Verse |
|---:|---|---|---|
| 9 | The Tall Tower | Pride | Proverbs 16:18 |
| 10 | God Calls Abraham | Covenant call | Genesis 12:2 |
| 11 | Stars in the Sky | Faith counted as righteousness | Genesis 15:6 |
| 12 | The Promised Son *(Isaac born)* | God's impossible faithfulness | Genesis 18:14 |
| 13 | God Provides a Lamb | Substitution | Genesis 22:8 |
| 14 | Jacob Learns Grace | Grace to the undeserving | Genesis 28:15 |
| 15 | Joseph and His Jealous Brothers | Providence in suffering | Genesis 50:20 |
| 16 | Joseph Forgives His Family *(capstone)* | Reconciliatory forgiveness | Genesis 50:21 |

---

## Phase 3 — World 3: God Rescues a People
*Moses, Passover, Exodus, the Law, the Tabernacle*

| Curriculum # | Story | New Concept | Key Verse |
|---:|---|---|---|
| 17 | Baby Moses Is Kept Safe | God hears oppression | Exodus 2:24 |
| 18 | God Calls from the Fire | God's holy name (I AM) | Exodus 3:14 |
| 19 | Let My People Go | Redeeming power | Exodus 6:6 |
| 20 | The Passover Lamb | Atoning blood | Exodus 12:13 |
| 21 | A Way Through the Sea | Salvation from helplessness | Exodus 14:14 |
| 22 | Bread in the Wilderness | Daily dependence | Exodus 16:4 |
| 23 | God's Good Commands | Moral law follows rescue | Exodus 20:2 |
| 24 | God Lives with His People *(capstone)* | Tabernacle presence | Exodus 25:8 |

---

## Phase 4 — Complete World 4: A Land Needing a King
*Joshua, Judges, Samuel — fills the gap before David*

| Curriculum # | Story | New Concept | Key Verse |
|---:|---|---|---|
| 25 | Twelve Spies and Two Trusting Hearts | Unbelief | Numbers 14:18 |
| 26 | Joshua and the Strong Walls | Courage from God's presence | Joshua 1:9 |
| 27 | Deborah Leads God's People | God uses willing servants | Judges 5:2 |
| 28 | Gideon's Tiny Army | God's strength in weakness | Judges 7:2 |
| 29 | Ruth Finds a Home | Covenant kindness to outsiders | Ruth 1:16 |
| 30 | Samuel Listens to God | Responsive hearing | 1 Samuel 3:10 |
| 31 | Saul: The King Who Would Not Listen | Partial obedience is disobedience | 1 Samuel 15:22 |
| *(32)* | *David the Shepherd Boy — already built (capstone)* | | |

---

## Phase 5 — Complete World 5: Heroes of Faith
*David's victory + failure + covenant; Elijah — fills gaps around Jonah & Daniel*

| Curriculum # | Story | New Concept | Key Verse |
|---:|---|---|---|
| 33 | David and the Giant | Representative victory | 1 Samuel 17:47 |
| 34 | David's Sin and God's Mercy | Repentance | Psalm 51:10 |
| 35 | God's Forever-King Promise | Davidic covenant | 2 Samuel 7:16 |
| 36 | Solomon Asks for Wisdom | Wisdom | Proverbs 2:6 |
| 37 | Elijah and the Only True God | Exclusive worship | 1 Kings 18:39 |
| *(38)* | *Jonah — already built* | | |
| *(39)* | *Daniel — already built* | | |
| 40 | The Prophets Promise New Hearts *(capstone)* | New covenant | Ezekiel 36:26 |

---

## Phase 6 — Complete World 6: Jesus Is Here
*Fills the Incarnation gap before Birth of Jesus*

| Curriculum # | Story | New Concept | Key Verse |
|---:|---|---|---|
| 41 | An Angel Visits Mary | Incarnation announced | Luke 1:37 |
| *(42)* | *Birth of Jesus — already built* | | |
| 43 | Visitors Worship the King *(Magi)* | Messiah for all nations | Matthew 2:11 |
| 44 | Jesus Grows and Obeys | Perfect human obedience | Luke 2:52 |
| 45 | Jesus Is Baptised | Trinity revealed | Matthew 3:17 |
| 46 | Jesus Says No to the Tempter | Sinlessness | Matthew 4:10 |
| 47 | Jesus Calls His Helpers | Discipleship | Mark 1:17 |
| *(48)* | *Jesus Loves Children — already built (capstone)* | | |

---

## Phase 7 — Complete World 7: The Compassionate King
*Fills teaching/miracle gap before the parables*

| Curriculum # | Story | New Concept | Key Verse |
|---:|---|---|---|
| 49 | Jesus Calms the Storm | Authority over creation | Mark 4:39 |
| 50 | Jesus Heals and Forgives | Authority to forgive sins | Mark 2:10 |
| 51 | Jesus Feeds the Crowd | Jesus the bread of life | John 6:35 |
| *(52–56)* | *Good Neighbour, Lost Sheep, Lost Son, How to Pray, Good Shepherd — already built* | | |

---

## Phase 8 — Complete World 8: Jesus Saves
*Fills the Passion Week gap before the cross*

| Curriculum # | Story | New Concept | Key Verse |
|---:|---|---|---|
| 57 | Jesus Raises Lazarus | Jesus: resurrection and life | John 11:25 |
| 58 | The King Rides into Jerusalem | Humble Messiah | Zechariah 9:9 |
| 59 | The Servant King Washes Feet | Servant kingship | John 13:15 |
| 60 | The Last Supper | New-covenant meal | Luke 22:20 |
| 61 | Jesus Prays in the Garden | Trust under anguish | Mark 14:36 |
| 62 | Jesus Dies for Sinners | Penal substitution | 1 Peter 3:18 |
| 63 | Jesus Is Alive | Bodily resurrection | Luke 24:6 |
| *(64)* | *Jesus Saves — already built (capstone)* | | |

---

## Phase 9 — World 9: Spirit-Filled Family
*All new — Pentecost through Sanctification*

| Curriculum # | Story | New Concept | Key Verse |
|---:|---|---|---|
| 65 | Jesus Returns to His Father | Ascension and reign | Matthew 28:20 |
| 66 | The Holy Spirit Comes | Indwelling Holy Spirit | Acts 1:8 |
| 67 | A New Sharing Family | Church | Acts 2:42 |
| 68 | Stephen Sees Jesus | Hope in persecution | Acts 7:56 |
| 69 | Saul Meets the Risen Jesus | New creation identity | 2 Corinthians 5:17 |
| 70 | Peter Welcomes Cornelius | One multiethnic people | Acts 10:34 |
| 71 | Paul and Silas Sing in Prison | Joy in suffering | Philippians 4:4 |
| 72 | The Spirit Grows Good Fruit *(capstone)* | Sanctification | Galatians 5:22 |

---

## Phase 10 — World 10: The King Makes All Things New
*All new — Perseverance, emotions, hope, eschatology*

| Curriculum # | Story | New Concept | Key Verse |
|---:|---|---|---|
| 73 | God's Armour for Hard Days | Spiritual perseverance | Ephesians 6:10 |
| 74 | When Anger Knocks | Righteous anger response | James 1:19 |
| 75 | When I Feel Alone | God's never-leaving presence | Hebrews 13:5 |
| 76 | When Life Feels Unfair | Lament and final justice | Psalm 73:28 |
| 77 | When Someone We Love Dies | Christian grief | 1 Thessalonians 4:13 |
| 78 | Jesus Will Come Again | Second coming | Acts 1:11 |
| 79 | The King Judges and Raises the Dead | Final judgment and resurrection | John 5:28 |
| 80 | God Makes Everything New *(capstone)* | New creation | Revelation 21:5 |

---

## Commissioning standard (from curriculum)

Every new story must pass all 10 checks — see `LITTLE_BIBLE_COMPLETE_CURRICULUM.md §Commissioning standard`:

1. Text fidelity — main claim comes from the cited passage
2. One-new-concept rule — only one new doctrine; all others retrieved
3. Metanarrative link — connects to promise/kingdom/rescue/presence thread
4. Gospel integrity — God's action primary; grace and faith clear
5. Christ connection — OT linked by promise, covenant, pattern, office, or fulfilment
6. Child safety — difficult content: truthful, calm, non-graphic, paired with "tell a trusted adult"
7. Age fit — concrete sentences, symbols explained from prior stories, one observable response
8. Memory and retrieval — assigned verse practised in context; at least one earlier truth retrieved
9. Global belonging — names, art, examples dignify African children and the worldwide church
10. Response — wonder, prayer, repentance, or Spirit-enabled action; no manufactured emotion
