import { defineProperties, createSprinkles } from "@vanilla-extract/sprinkles";
import { vars } from "./theme.css.ts";

const responsive = defineProperties({
  conditions: {
    mobile: {},
    lg: { "@media": "screen and (min-width: 1024px)" },
  },
  defaultCondition: "mobile",
  properties: {
    display: ["block","inline-block","flex","grid","none"],
    flexDirection: ["row","column"],
    alignItems: ["stretch","center","start","end"],
    justifyContent: ["start","center","space-between"],
    gap: { none: "0", sm: "8px", md: "16px", lg: "24px" },
    padding: { none:"0", sm:"8px", md:"16px", lg:"24px" },
    paddingTop: { none:"0", sm:"8px", md:"16px" },
    paddingBottom: { none:"0", sm:"8px", md:"16px" },
    marginTop: { none:"0", sm:"8px", md:"16px", lg:"24px" },
    width: ["100%","auto"],
    textAlign: ["left","center"],
    fontWeight: ["400","500","600","700"],
    borderRadius: { sm: vars.radius.sm, md: vars.radius.md, xl: vars.radius.xl },
    color: { text: vars.color.text, subtle: vars.color.subtle, white: "#fff" },
    background: { surface: vars.color.surface, primary: vars.color.primary },
  },
  shorthands: {
    p: ["padding"],
    pt: ["paddingTop"],
    pb: ["paddingBottom"],
    mt: ["marginTop"],
  },
});
export const sprinkles = createSprinkles(responsive);
export type Sprinkles = Parameters<typeof sprinkles>[0];
