import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.makePresentModule(
    .organization,
    dependencies: [
        .usecase(.organization),
        .entity(.organization)
    ]
)
