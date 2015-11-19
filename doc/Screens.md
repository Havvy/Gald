Problem: Each screen has its own data, but we don't want to have ad-hoc
implementations for each and every screen.

Solution: Figure out what the common data for each screen is, and put those
in a data structure.

---

So, what do all screens have?

* Title
* Pictures
* Body Text
* Options
* Who can choose options?

Based on this, let's use the following as a basis:

```
type Time: Number

struct Screen {
  title: String;
  pictures: ScreenPictures;
  body: String;
  options: [String],
  time: Time
};

struct ScreenPictures {
  height: Number;
  width: Number;
  urls: [Name];
};
```

Note that if there are no `urls` (a.k.a. an empty list), then `height` and
`width` should be assigned to `0`.

You'll also notice we don't show _who_ can choose options. Instead, only the
person whose turn it is can choose, and that information is given though a
separate message.